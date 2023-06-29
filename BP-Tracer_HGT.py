#!/usr/bin/python3
import os
import argparse
import sys
import time
import pandas as pd
"""
添加参数模块
"""
parser = argparse.ArgumentParser(description='BP-Tracer_HGT')
parser.add_argument('--file',help='The contig list table')
parser.add_argument('--pwd', type=str, default='./',help='The outputPWD of file (default: ./)')
parser.add_argument('--threads', type=int, default=40, help='Number of threads to use (default: 40)')
args = parser.parse_args()


def progress_bar():
    for i in range(1, 101):
        print("\r", end="")
        print("Running progress: {}%: ".format(i), "▋" * (i // 2), end="")
        sys.stdout.flush()
        time.sleep(0.0005)

def mkdir(path):
    folder = os.path.exists(path)
    if not folder:  # 判断是否存在文件夹如果不存在则创建为文件夹
        os.makedirs(path)  # 创建文件时如果路径不存在会创建这个路径
        print("---  new folder...  ---")

    else:
        print("---  There is this folder!  ---")


"""
获取软件的路径
一定要注意先把相对路径转成绝对路径，不然后面进入输出文件夹就会出问题！
"""
abs=os.path.split(os.path.realpath(__file__))[0]
abs_raw=os.path.realpath(args.file)
abs_db=abs+"/DB_HGT"

print(f"""
The PWD of workplace is: {abs}
The PWD of otu file is: {abs_raw}
""")


"""
创建文件夹，定义输出路径
"""
# 先读取进来，不然路径不对的话可能会出问题，相对路径发生改变了
# raw_fq_list = pd.read_csv("./Example/raw.fq.list",sep="\t",header=None)
# 创建这个路径，并在这个路径下操作任务
mkdir(args.pwd)
os.chdir(args.pwd)
mkdir("BP-Tracer_HGT")
mkdir("shell")

raw_fq_list = pd.read_csv(abs_raw,sep="\t",header=None)
ID_list = raw_fq_list[0]
contig_list=raw_fq_list[1]
num = ID_list.shape[0]



PWD=os.getcwd()
abs_shell=PWD+"/shell/"
""
for i in range(0,num,1):
    ID = ID_list[i]
    contig=contig_list[i]
    mode = PWD+"/shell/"+'S01.1.'+ID+'{}'
    f = open(mode.format(".HGT") + '.sh', 'w', encoding='utf-8')
    content = (f"""
cd {PWD}
cd BP-Tracer_HGT
waafle_search --threads {args.threads} {contig} {abs_db}/UnigeneSet-waafledb.v1.fa --out {ID}.blastout;
waafle_genecaller {ID}.blastout; 
# 自动生成{ID}.gff
waafle_orgscorer {contig}  {ID}.blastout {ID}.gff {abs_db}/UnigeneSet-waafledb.v1.taxonomy
""")
    f.write(content)
f.close()


# 显示运行成功！
print("""

      ___       ___           ___           ___           ___     
     /\__\     /\  \         /\  \         /\__\         /\  \    
    /:/  /    /::\  \       /::\  \       /::|  |       /::\  \   
   /:/  /    /:/\:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \  
  /:/  /    /:/  \:\  \   /::\~\:\  \   /:/|:|__|__   /::\~\:\  \ 
 /:/__/    /:/__/ \:\__\ /:/\:\ \:\__\ /:/ |::::\__\ /:/\:\ \:\__\\
 \:\  \    \:\  \ /:/  / \/_|::\/:/  / \/__/~~/:/  / \:\~\:\ \/__/
  \:\  \    \:\  /:/  /     |:|::/  /        /:/  /   \:\ \:\__\  
   \:\  \    \:\/:/  /      |:|\/__/        /:/  /     \:\ \/__/  
    \:\__\    \::/  /       |:|  |         /:/  /       \:\__\    
     \/__/     \/__/         \|__|         \/__/         \/__/                                        
It Works        
""")
print(f"""
Please note that your input！！！
file:{args.file}
pwd:{args.pwd}
""")
progress_bar()



