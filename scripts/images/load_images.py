import os
import asyncio
import subprocess
import logging
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

# Setup logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


# Helper function to run shell commands asynchronously
async def run_command(command: str):
    logging.info(f"Executing command: {command}")
    process = await asyncio.create_subprocess_shell(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    stdout, stderr = await process.communicate()

    if stdout:
        logging.info(f"[stdout]\n{stdout.decode()}")
    if stderr:
        logging.error(f"[stderr]\n{stderr.decode()}")

    if process.returncode != 0:
        raise Exception(f"Command failed: {command}")


# Function to login to Docker registry (source or target)
async def docker_login(registry: str, username: str, password: str):
    logging.info(f"Logging into Docker registry: {registry}")
    login_command = f"echo {password} | docker login {registry} --username {username} --password-stdin"
    await run_command(login_command)


# Function to pull Docker image from the source registry
async def pull_image(
    image_name: str, image_tag: str, registry: str, username: str, password: str
):
    await docker_login(registry, username, password)

    # Pull the image
    full_image_name = f"{registry}/{image_name}:{image_tag}"
    logging.info(f"Pulling image {full_image_name} from {registry}")
    pull_command = f"docker pull {full_image_name}"
    await run_command(pull_command)


# Function to tag and push Docker image to the target registry
async def push_image(
    image_name: str,
    image_tag: str,
    source_registry: str,
    target_registry: str,
    username: str,
    password: str,
):
    source_image = f"{source_registry}/{image_name}:{image_tag}"
    target_image = f"{target_registry}/{image_name}:{image_tag}"

    logging.info(f"Tagging image {source_image} for target registry {target_registry}")

    # Tag the image for the target registry
    tag_command = f"docker tag {source_image} {target_image}"
    await run_command(tag_command)

    # Log into target registry
    await docker_login(target_registry, username, password)

    # Push the image to the target registry
    logging.info(f"Pushing image {target_image}")
    push_command = f"docker push {target_image}"
    await run_command(push_command)


# Function to get image digest (SHA) from Docker
async def get_image_sha(image_name: str, image_tag: str, registry: str):
    full_image_name = f"{registry}/{image_name}:{image_tag}"

    # Inspect the image to get its digest (SHA)
    inspect_command = (
        f"docker inspect --format='{{{{.RepoDigests}}}}' {full_image_name}"
    )
    logging.info(f"Inspecting image {full_image_name} for digest (SHA)")
    process = await asyncio.create_subprocess_shell(
        inspect_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        logging.error(f"Failed to inspect image: {stderr.decode()}")
        return None

    if stdout:
        digest_info = stdout.decode().strip().strip("[]")
        logging.info(f"Digest found: {digest_info}")
        return digest_info

    return None


# Function to check if the image already exists in the target registry
async def image_exists_in_target(
    image_name: str, image_tag: str, target_registry: str, username: str, password: str
):
    # Login to target registry
    await docker_login(target_registry, username, password)

    # Construct the full image name for the target registry
    full_image_name = f"{target_registry}/{image_name}:{image_tag}"
    logging.info(
        f"Checking if image {full_image_name} already exists in target registry"
    )

    # Get the SHA of the image in the source registry
    source_sha = await get_image_sha(image_name, image_tag, target_registry)

    # Pull the image from the target registry to check if it exists
    check_command = f"docker pull {full_image_name}"
    process = await asyncio.create_subprocess_shell(
        check_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    await process.communicate()

    if process.returncode == 0:
        # If pull is successful, the image exists. Now check the SHA.
        target_sha = await get_image_sha(image_name, image_tag, target_registry)

        # Compare the SHAs
        if source_sha == target_sha:
            logging.info(
                f"Image {full_image_name} exists in target registry and SHA matches."
            )
            return True
        else:
            logging.warning(
                f"Image {full_image_name} exists in target registry, but SHA does not match."
            )
            return False

    logging.info(f"Image {full_image_name} does not exist in target registry.")
    return False


# Main function to handle the transfer process
async def transfer_image(
    image_name: str, image_tag: str, source_registry: str, target_registry: str
):
    # Get credentials from environment variables loaded from the .env file
    source_username = os.getenv("SOURCE_REGISTRY_USERNAME")
    source_password = os.getenv("SOURCE_REGISTRY_PASSWORD")
    target_username = os.getenv("TARGET_REGISTRY_USERNAME")
    target_password = os.getenv("TARGET_REGISTRY_PASSWORD")

    if not source_username or not source_password:
        raise Exception(
            "Source registry credentials are missing in environment variables."
        )
    if not target_username or not target_password:
        raise Exception(
            "Target registry credentials are missing in environment variables."
        )

    # Check if the image already exists in the target registry
    if await image_exists_in_target(
        image_name, image_tag, target_registry, target_username, target_password
    ):
        logging.info(
            f"Image {image_name}:{image_tag} already exists in target registry {target_registry}. Skipping transfer."
        )
        return

    # Pull the image from the source registry
    await pull_image(
        image_name, image_tag, source_registry, source_username, source_password
    )

    # Push the image to the target registry
    await push_image(
        image_name,
        image_tag,
        source_registry,
        target_registry,
        target_username,
        target_password,
    )


# Function to run the image transfer tasks
async def main():
    # List of images to transfer: (image_name, image_tag)
    images_to_transfer = [
        # ("sarvam-vad-service", "v0.1.2"),
        # ("auth-service", "v0.2.2"),
        # ("sarvam-app-runtime-service", "v0.1.35"),
        ("knowledge-base-service", "v0.1.93"),
    ]

    source_registry = "gitopsdocker.azurecr.io"
    target_registry = "uidaimodels.azurecr.io"

    # Run the transfer process asynchronously for all images
    await asyncio.gather(
        *[
            transfer_image(image_name, image_tag, source_registry, target_registry)
            for image_name, image_tag in images_to_transfer
        ]
    )


if __name__ == "__main__":
    asyncio.run(main())
