        
        ln -s 2XWR_A_ASP148GLU.pdb input.pdb
        
        CABSflex            -i input.pdb            -k 20            -v 3            -s 50            -y 50            -a 20            -A            -z 10            -C             --dssp-command /usr/local/dssp-3.0.10/bin/mkdssp            --ca-rest-add 179:A 176:A 5.5 1.0 --ca-rest-add 179:A 238:A 6.6 1.0 --ca-rest-add 179:A 242:A 8.1 1.0 --ca-rest-add 176:A 238:A 7.1 1.0 --ca-rest-add 176:A 242:A 6.5 1.0 --ca-rest-add 238:A 242:A 6.7 1.0 --sc-rest-add 179:A 238:A 4.8 1.0 --sc-rest-add 179:A 242:A 6.0 1.0 --sc-rest-add 179:A 176:A 5.4 1.0 --sc-rest-add 176:A 242:A 4.0 1.0 --sc-rest-add 176:A 238:A 6.7 1.0 --sc-rest-add 238:A 242:A 5.1 1.0            --log
