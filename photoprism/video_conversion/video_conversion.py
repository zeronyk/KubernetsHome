import argparse
import oc_functions as os_func
import subprocess
import os, re


#process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
#output, error = process.communicate()


#convertion_path = "/home/hermel/test_videos"
convertion_path = "/media/hermel/74899650-ece9-432d-8482-65403c32de3c/plaincopy"


## check for files 
vob_list = os_func.get_files(convertion_path, ".vob")


for path, vob_file in vob_list:
    last = os.path.split(path)[-1]
    # tail from tail
    prelast = os.path.split(os.path.split(path)[-2])[-1]
    preprelast = os.path.split(os.path.split(os.path.split(path)[-2])[-2])[-1]
    outputname = f'{preprelast}_{prelast}_{last}_{os.path.splitext(vob_file)[0]}.mp4'
    input_path = os.path.join(path, vob_file)
    output_path = os.path.join(path, outputname)
    bashCommand = f'ffmpeg -y -hwaccel cuda -i {input_path} -vcodec h264_nvenc -acodec copy {output_path}'
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    process.wait()
    if (process.returncode == 0):
        os.remove(os.path.join(path, vob_file))
    else: 
        try:
            os.remove(os.path.join(path,outputname))
        except: 
            print("process failed and did not remove false outputfile")
