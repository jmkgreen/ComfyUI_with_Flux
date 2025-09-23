# ComfyUI Fast

## Fork of ValyrianTech

This project is based on [ValyrianTech/ComfyUI_with_Flux](https://github.com/ValyrianTech/ComfyUI_with_Flux). What's happened in this fork?

* Added a GitHub Workflow to build the Docker image
* Upgraded to the latest Nvidia CUDA and other libraries
* `/workspace/venv` hosts all Python software for ComfyUI purposes
* Dropped the variant with models included
* Updated the scripts to allow end-users with a storage volume to download the large model files on their first demand

## Model Files

AI models are not included in this Docker image. The reasons include:

* Deployment speed. Downloading the Docker image to a RunPod pod was frustratingly slow even using the _without-Flux_ variant.
* Many models. What started with Stable Diffusion has quickly expanded with an ever-diverse set of multi-gigabyte files. Many models also have multiple versions.

Instead of shipping models that may or may not be required by _you_, this Docker image ships with scripts to download those that you can elect to use. The models are just files, and they are downloaded to `/workspace` which is exactly where RunPod expects to mount your persistent storage. If you terminate your pod then later launch another based on the same storage, your models will be there ready.

So, run the script that corresponds to download the models you want, and do this once only. It is up to you to remove the model files to free up storage space if needed, or expand the storage volume.

### Hugging Face

Some scripts download files from Hugging Face. Some of these require authentication. To support this, launch your pod with an environment variable named `HF_TOKEN` set to your own Hugging Face token.

## ComfyUI Updates

The Docker image built by this source project will have an up-to-date ComfyUI included. However, this ComfyUI will only be copied into your `/workspace/ComfyUI` if this doesn't already exist. First run with a new `/workspace`: you'll get the latest version; beyond this you need to run ComfyUI updates yourself which is easy to do within the UI itself.

## Original Documentation

## API
There is an example python script in the 'examples' folder that demonstrates how to interact with the ComfyUI API.
It will add a new workflow to the queue, then periodically check the status of the workflow until it is completed.
When the workflow is completed, a download link will be printed to the console.

To run the example script you need to run a command like this, replacing the IP address, port, and filepath with the appropriate values:
```
python api_example.py --ip 194.68.245.38 --port 22018 --filepath workflow_api_format.json
```

Optionally, you can also specify a new prompt for the workflow:
```
python api_example.py --ip 194.68.245.38 --port 22018 --filepath workflow_api_format.json --prompt "platinum blonde woman with magenta eyes"
```

[api_example.py](https://github.com/ValyrianTech/ComfyUI_with_Flux/blob/main/examples/api_example.py)

You can find your IP address and port in the 'TCP Port Mappings' section when you click the 'Connect' button on the Runpod.io.
You will need the Public IP and the External Port.
![TCP Port Mappings](https://github.com/ValyrianTech/ComfyUI_with_Flux/blob/main/tcp_port_mappings.png?raw=true)

If you want to use a different workflow, keep in mind you must use the API format of the workflow, you can get this by clicking the 'Save (API Format)' button in the ComfyUI.

## JupyterLab
You can use JupyterLab to upload files to your pod, like custom LoRa models or other files.

Click on the "Connect to HTTP Service [Port 8888]" button to open JupyterLab.
You will be asked for a token, this will be different each time you deploy a new pod.

The token can be seen in the logs of the runpod template:

![JupyterLab token](https://github.com/ValyrianTech/ComfyUI_with_Flux/blob/main/JupyterLab_token.png?raw=true)

Alternatively, you can start the web terminal and connect to it and enter the command "jupyter server list" to get the token.

Note: Due to a technical peculiarity in JupyterLab, the folder /ComfyUI/models/checkpoints will not open, because 'checkpoints' is a special word in JupyterLab.
If you need to copy a file in this folder, you can still connect via the web terminal and use the 'wget' command to download your file.


The _original_ `README.md` document can now be found as `README-old.md`.