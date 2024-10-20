#!/usr/bin/python3
import typer
# import os
# import shutil
# import pathlib
import subprocess

typ = typer.Typer()

def cmd(cmd: str):
    subprocess.run(["ls","-alhn"])

@typ.command()
def test(name: str):
    print(f"Hello {name}")
    cmd(name)


if __name__ == "__main__":
    typ()