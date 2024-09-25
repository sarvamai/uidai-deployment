# Docker Image Transfer Script

This Python script transfers Docker images from one registry to another using asynchronous programming with `asyncio`. It handles the complete process of logging into Docker registries, pulling images, checking if images already exist in the target registry, and pushing images to the target registry.

## Prerequisites

- Python 3.7 or higher
- Docker installed and configured
- Required Python packages (see Installation section)
- Access credentials for both source and target Docker registries

## Installation

1. Create a `.env` file in the root directory of the project with the following environment variables:

   ```plaintext
   SOURCE_REGISTRY_USERNAME=<your_source_registry_username>
   SOURCE_REGISTRY_PASSWORD=<your_source_registry_password>
   TARGET_REGISTRY_USERNAME=<your_target_registry_username>
   TARGET_REGISTRY_PASSWORD=<your_target_registry_password>
   ```

2. Install the required packages:

   ```bash
   pip3 install python-dotenv
   ```

## Usage

1. Modify the `images_to_transfer` list, `source_registry` and `target_registry` in the `main` function to include the images you want to transfer. Each entry should be a tuple with the image name and tag:

   ```python
   images_to_transfer = [
       ("image_name_1", "tag_1"),
       ("image_name_2", "tag_2"),
   ]

   source_registry = "docker.registry.io"
   target_registry = "docker.registry.io"

   ```

2. Run the script:

   ```bash
   python transfer_image.py
   ```
