#python 3.9.2
#encoding=utf-8

import sys

if len(sys.argv)==1:
    print("This tool is for finding duplicated encodings.\nduplook.py <sfd file>")
else:
    f=open(sys.argv[1])
    unicode_count=[0]*65536
    dup_count=0
    while True:
        line=f.readline()
        if line=="":
            break
        if line[:9]=="Encoding:":
            sp=line.split()
            try:
                cid1=int(sp[1])
                unicode=int(sp[2])
                if unicode==-1:
                    continue
                elif unicode>=65536:
                    print("Skip char: ["+chr(unicode)+"] "+hex(unicode))
                    continue
                cid2=int(sp[3])
                unicode_count[unicode]=unicode_count[unicode]+1
                if unicode_count[unicode]>1:
                    print("Duplicated char: ["+chr(unicode)+"] "+hex(unicode))
                    dup_count=dup_count+1
            except ValueError:
                continue
    print("Total duplication: "+str(dup_count))
