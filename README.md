# emboss
Container image for EMBOSS utilities.

## Quick Usage

```bash
# Pull the image
docker pull docker.io/picotainers/emboss:latest

# Run the tool
docker run --rm docker.io/picotainers/emboss:latest emboss --help
```

## Usage with mounted data

```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/emboss:latest emboss --help
```
