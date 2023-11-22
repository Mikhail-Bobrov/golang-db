import os, subprocess, click
from sys import exit

# Error handlers:
def is_docker_exists():
    try:
        subprocess.run(["docker", "--version"], check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except subprocess.CalledProcessError:
        print("Docker is not available. Please install Docker to continue")
        return exit(1)

def is_file_exists():
    try:
        open(f"{filename}", "r")
        return True
    except OSError:
        print("File not found")
        return exit(1)
# End of error handlers

is_docker_exists()
filename = input("Please provide filename with docker images list: ")
is_file_exists()

# Customize field:
f = open(f"{filename}", "r") # Filename with images list (need to be in current dir). Replace "file" with your filename

tar_name = input("Enter result archive name (without .tar): ")
source_repo = input("Spicify source registry with project (for exmpl 'harbor.altezza.org/frisbee'): ")
target_repo = input("Spicify source registry with project (for exmpl 'registry.msk.cht/tdm'): ")

# End of customize field

source_registry_content = []
target_registry_content = []

class Images:

    def __init__(self, source_content, target_content):
        self.source_content = source_content
        self.target_content = target_content

    def build_source_content(self):
        for i in f:
            self.source_content.append(i.strip('\n'))
        print(self.source_content)

    def pull_images(self):
        for i in self.source_content:
            os.system(f"docker pull {i}")
        return print(f"Images were pulled.")

    def tag_images(self):
        for i in self.source_content:
            self.target_content.append(i.replace(f'{source_repo}', f'{target_repo}'))
        print(self.target_content)
        if click.confirm(f"Are you agree with the result?", default=True):
            for i in range(len(self.source_content)):
                print(f"{self.source_content[i]} {self.target_content[i]}")
                os.system(f"docker tag {self.source_content[i]} {self.target_content[i]}")
            print("Images were tagged.")
        else:
            exit(1)
        return self.target_content

    def save_docker_images(self):
        images_list = " ".join(self.target_content)
        print("Start saving images...")
        os.system(f"docker save {images_list} > {tar_name}.tar")
        print("Images were saved. Please check it.")
        return images_list

# Object declaration:
docker_object = Images(source_registry_content, target_registry_content)

# Class methods:
docker_object.build_source_content()
docker_object.pull_images()
docker_object.tag_images()
docker_object.save_docker_images()
