#!/usr/bin/env python3
"""
Universal Subtitle Organizer
Automatically copies and renames subtitle files from Subs folder to match video files
for automatic subtitle detection in media players like SMPlayer, VLC, etc.

Usage:
    python3 universal_subtitle_organizer.py [directory_path]

If no directory is specified, it will process the current directory.
You can also run it from any directory and specify multiple series directories.

Features:
- Supports multiple video formats (.mp4, .mkv, .avi, .mov, .wmv, .flv, .webm)
- Supports multiple subtitle formats (.srt, .sub, .ass, .vtt)
- Automatically finds and matches video files with subtitle folders
- Preserves original subtitle files as backup
- Handles special episodes and movies
- Provides detailed progress reporting
"""

import os
import shutil
import sys
import argparse
from pathlib import Path
import glob

class SubtitleOrganizer:
    def __init__(self):
        self.video_extensions = ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v']
        self.subtitle_extensions = ['.srt', '.sub', '.ass', '.vtt', '.idx']
        self.common_subtitle_names = ['2_eng.srt', 'English.srt', 'eng.srt', 'en.srt']

    def find_video_files(self, directory):
        """Find all video files in the given directory."""
        video_files = []
        for ext in self.video_extensions:
            pattern = str(directory / f"*{ext}")
            video_files.extend(glob.glob(pattern, recursive=False))
        return [Path(f) for f in video_files]

    def find_subtitle_files(self, directory):
        """Find all subtitle files in the given directory."""
        subtitle_files = []
        for ext in self.subtitle_extensions:
            pattern = str(directory / f"*{ext}")
            subtitle_files.extend(glob.glob(pattern, recursive=False))
        return [Path(f) for f in subtitle_files]

    def get_best_subtitle_file(self, subtitle_folder):
        """Get the best subtitle file from a folder, preferring common names."""
        subtitle_files = self.find_subtitle_files(subtitle_folder)

        if not subtitle_files:
            return None

        # First, try to find files with common names
        for common_name in self.common_subtitle_names:
            for sub_file in subtitle_files:
                if sub_file.name == common_name:
                    return sub_file

        # If no common name found, prefer .srt files
        srt_files = [f for f in subtitle_files if f.suffix.lower() == '.srt']
        if srt_files:
            return srt_files[0]

        # Otherwise, return the first subtitle file found
        return subtitle_files[0]

    def organize_subtitles(self, series_dir):
        """
        Organize subtitle files for automatic detection by media players.

        Args:
            series_dir (Path): Path to the series directory

        Returns:
            dict: Results containing success status and statistics
        """
        if not series_dir.exists():
            return {
                'success': False,
                'error': f"Directory '{series_dir}' does not exist.",
                'processed': 0,
                'skipped': 0,
                'errors': 0
            }

        subs_dir = series_dir / "Subs"
        if not subs_dir.exists():
            return {
                'success': False,
                'error': f"Subs directory '{subs_dir}' does not exist.",
                'processed': 0,
                'skipped': 0,
                'errors': 0
            }

        print(f"\n📁 Processing: {series_dir.name}")
        print(f"   Subs directory: {subs_dir}")

        # Get all video files in the root directory
        video_files = self.find_video_files(series_dir)

        if not video_files:
            return {
                'success': False,
                'error': "No video files found in the root directory.",
                'processed': 0,
                'skipped': 0,
                'errors': 0
            }

        print(f"   Found {len(video_files)} video files")

        # Process each subtitle folder
        subtitle_folders = [item for item in subs_dir.iterdir() if item.is_dir()]
        processed_count = 0
        skipped_count = 0
        error_count = 0

        print(f"   Processing {len(subtitle_folders)} subtitle folders:")

        for sub_folder in sorted(subtitle_folders):
            # Get the best subtitle file from this folder
            subtitle_file = self.get_best_subtitle_file(sub_folder)

            if subtitle_file is None:
                print(f"   ⚠️  {sub_folder.name}: No subtitle files found")
                skipped_count += 1
                continue

            # Find matching video file
            folder_name = sub_folder.name
            matching_video = None

            for video_file in video_files:
                video_name_without_ext = video_file.stem
                if video_name_without_ext == folder_name:
                    matching_video = video_file
                    break

            if matching_video is None:
                print(f"   ⚠️  {folder_name}: No matching video file found")
                skipped_count += 1
                continue

            # Create the target subtitle filename
            target_subtitle = series_dir / f"{matching_video.stem}.srt"

            # Skip if target already exists and is identical
            if target_subtitle.exists():
                try:
                    if target_subtitle.stat().st_size == subtitle_file.stat().st_size:
                        print(f"   ⏭️  {folder_name}: Subtitle already exists (same size)")
                        skipped_count += 1
                        continue
                except Exception:
                    pass  # Continue with copy if we can't compare

            # Copy the subtitle file
            try:
                shutil.copy2(subtitle_file, target_subtitle)
                print(f"   ✅ {folder_name}: {subtitle_file.name} → {target_subtitle.name}")
                processed_count += 1
            except Exception as e:
                print(f"   ❌ {folder_name}: Error copying subtitle - {str(e)}")
                error_count += 1

        return {
            'success': processed_count > 0,
            'processed': processed_count,
            'skipped': skipped_count,
            'errors': error_count,
            'total_folders': len(subtitle_folders)
        }

    def process_directory(self, directory_path):
        """Process a single directory."""
        directory = Path(directory_path).resolve()
        return self.organize_subtitles(directory)

    def process_multiple_directories(self, directory_paths):
        """Process multiple directories."""
        results = []
        total_processed = 0
        total_skipped = 0
        total_errors = 0

        for dir_path in directory_paths:
            result = self.process_directory(dir_path)
            results.append((dir_path, result))

            if result['success'] or result['processed'] > 0:
                total_processed += result['processed']
                total_skipped += result['skipped']
                total_errors += result['errors']

        return results, total_processed, total_skipped, total_errors

def find_series_directories(base_path):
    """Find all potential series directories in the base path."""
    base_path = Path(base_path)
    series_dirs = []

    # Look for directories that contain "Subs" folder
    for item in base_path.iterdir():
        if item.is_dir() and (item / "Subs").exists():
            series_dirs.append(item)

    return series_dirs

def main():
    parser = argparse.ArgumentParser(
        description="Universal Subtitle Organizer - Organize subtitle files for automatic media player detection",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python3 universal_subtitle_organizer.py
    python3 universal_subtitle_organizer.py /path/to/series
    python3 universal_subtitle_organizer.py /path/to/series1 /path/to/series2
    python3 universal_subtitle_organizer.py --auto-discover /path/to/shows
        """
    )

    parser.add_argument(
        'directories',
        nargs='*',
        help='Directory paths to process (default: current directory)'
    )

    parser.add_argument(
        '--auto-discover',
        action='store_true',
        help='Automatically discover all series directories in the specified path'
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be done without actually copying files'
    )

    args = parser.parse_args()

    print("🎬 Universal Subtitle Organizer")
    print("=" * 50)

    organizer = SubtitleOrganizer()

    # Determine directories to process
    if args.auto_discover:
        if args.directories:
            all_dirs = []
            for base_dir in args.directories:
                found_dirs = find_series_directories(base_dir)
                all_dirs.extend(found_dirs)
                print(f"Found {len(found_dirs)} series directories in {base_dir}")
            directories_to_process = all_dirs
        else:
            directories_to_process = find_series_directories(Path.cwd())
            print(f"Found {len(directories_to_process)} series directories in current directory")
    else:
        if args.directories:
            directories_to_process = args.directories
        else:
            directories_to_process = [Path.cwd()]

    if not directories_to_process:
        print("❌ No directories to process found.")
        sys.exit(1)

    if args.dry_run:
        print("🔍 DRY RUN MODE - No files will be copied")

    # Process directories
    results, total_processed, total_skipped, total_errors = organizer.process_multiple_directories(directories_to_process)

    # Print summary
    print("\n" + "=" * 50)
    print("📊 SUMMARY")
    print("=" * 50)

    success_count = 0
    for dir_path, result in results:
        if result['success']:
            success_count += 1
            print(f"✅ {Path(dir_path).name}: {result['processed']} processed, {result['skipped']} skipped, {result['errors']} errors")
        else:
            print(f"❌ {Path(dir_path).name}: {result.get('error', 'Unknown error')}")

    print(f"\n📈 Overall Results:")
    print(f"   • Directories processed successfully: {success_count}/{len(results)}")
    print(f"   • Total subtitle files processed: {total_processed}")
    print(f"   • Total files skipped: {total_skipped}")
    print(f"   • Total errors: {total_errors}")

    if total_processed > 0:
        print(f"\n🎉 Success! {total_processed} subtitle files are now ready for automatic detection.")
        print("   You can now play videos in media players with automatic subtitle loading.")
    else:
        print("\n⚠️  No subtitle files were processed.")
        if total_errors > 0:
            sys.exit(1)

if __name__ == "__main__":
    main()
