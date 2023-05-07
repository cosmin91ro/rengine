#!/usr/bin/env python3
import subprocess
import os
from reNgine.definitions import *


def run(domainName, resultsDir, yaml_configuration):
    outDir = os.path.join(resultsDir, 'subdomaindiscovery')
    try:
        os.makedirs(outDir)
    except FileExistsError:
        pass
    outFile = f'{os.path.join(outDir, os.path.basename(os.path.splitext(__file__)[0]))}.out'
    threads = yaml_configuration[THREADS] if yaml_configuration[THREADS] else 10
    command = f'python3 /usr/src/github/Sublist3r/sublist3r.py -d {domainName} -t {threads} -o {outFile}'
    print(f'running {command} ...\n')
    proc = subprocess.run(command, shell=True, capture_output=True)
    return proc.returncode



if __name__ == '__main__':
    rcode = run('cwavesoftware.com', './out')
    print (f'{os.path.basename(__file__)} completed with status code {rcode}')
    print('Done')