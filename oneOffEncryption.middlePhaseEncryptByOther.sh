arbitraryFile=$1

#email the publickey.pem to someone
#then that person runs this:
openssl rand -base64 128 -out key.bin
openssl enc -aes-256-cbc -salt -in $arbitraryFile -out arbitraryFile.enc -pass file:./key.bin
openssl rsautl -encrypt -inkey publickey.pem -pubin -in key.bin -out key.bin.enc
#the someone emails two files, the encrypted symetric key, and the arbitraryFile encrypted with that symetric key back to you

