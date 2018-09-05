arbitraryFile=$1


#generate a new RSA public/private key pair, and output the publickey.pem
openssl genrsa -des3 -out certificate.pem 2048
openssl rsa -in certificate.pem -out publickey.pem -outform PEM -pubout


#email the publickey.pem to someone
#then that person runs this:
openssl rand -base64 128 -out key.bin
openssl enc -aes-256-cbc -salt -in $arbitraryFile -out arbitraryFile.enc -pass file:./key.bin
openssl rsautl -encrypt -inkey publickey.pem -pubin -in key.bin -out key.bin.enc
#the someone emails two files, the encrypted symetric key, and the arbitraryFile encrypted with that symetric key back to you


#decrypt the symetric key with your private key certificate
openssl rsautl -decrypt -inkey certificate.pem -in key.bin.enc -out key.bin
#and then decrypt the arbitraryFile with that symetric key
openssl enc -d -aes-256-cbc -in arbitraryFile.enc -out arbitraryFile.unenc -pass file:./key.bin

#check the arbitraryFile for correctness,
#and then delete the privateKey certificate
