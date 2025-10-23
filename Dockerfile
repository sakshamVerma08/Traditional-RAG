# Stage 1 : Builds the application
FROM python:3.11-slim AS builder

WORKDIR /app 

# Tell Pip to disable caching, because we don't want to store our python packages inside Image Layers.
ENV PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv  

# PYTHON UNBUFFERED = 1 means that all the logs will be sent to stdout/stderrs , which comes handy in containers.
#VENV_PATH is the actual path where the venv inside our image will exist.


# Now we install all the system packages
# We are downloading gcc and other compilers in our image because many Python-based packages require compilers to function.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    git \
    curl \
    libffi-dev \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


# Creating a Virtual Env inside the Builder image and upgrading the pip
RUN python -m venv ${VENV_PATH}
ENV PATH = "${VENV_PATH}/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel 


# Copying only dependencies first to optimize Docker cache.

COPY requirements.txt .

# Install python dependencies into VENV
# Make sure to use --no-cache-dir to keep the image size small

RUN pip install --no-cache-dir -r requirements.txt jupyter nbconvert


# The following packages are used so that when the container runs, it executes the jupyter notebook as a jupyter server. This
# is done because we can't directly give .ipynb extension files to Docker to run




# STage 2: Final Stage

FROM python:3.11-slim AS runner

# Create a Non-root user (for better security)
RUN useradd --create-home appuser

WORKDIR /app



# Copy the prebuilt venv from builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure venv bin is first on PATH

ENV PATH = "/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1


# Copy only what's needed for runtime

COPY Notebook/ ./Notebook
COPY README.md .
COPY main.py .
COPY data/pdf_files/ ./data/pdf_files/


# create an unprivileged user and change ownership

RUN chown -R appuser:appuser /app /opt/venv

USER appuser

EXPOSE 8888

# Start Jupyter Notebook server (interactive mode)
ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

