FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    MITOGEX_DIR=/opt/mitogex \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:/opt/mitogex/Software/bwa-mem2:/opt/mitogex/Software/gatk:/opt/mitogex/Software/haplogrep3:$PATH

# Robust apt-get with retries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    git \
    bzip2 \
    unzip \
    build-essential \
    libpq-dev \
    jq \
    r-base-core \
    default-jre \
    default-jdk \
    bc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Miniconda manually (Architecture Aware)
RUN arch=$(uname -m) && \
    if [ "$arch" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"; \
    elif [ "$arch" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"; \
    else \
        echo "Unsupported architecture: $arch"; exit 1; \
    fi && \
    wget --quiet $MINICONDA_URL -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

WORKDIR /app

# Copy environment files and create environments
COPY mitogex.yml mitogex_ete.yml ./
RUN /opt/conda/bin/conda env create -f mitogex_ete.yml && \
    /opt/conda/bin/conda env create -f mitogex.yml && \
    /opt/conda/bin/conda clean -afy

# Install Python dependencies for Celery worker
COPY backend/requirements.txt ./requirements.txt
RUN /opt/conda/bin/pip install --no-cache-dir -r requirements.txt

# Install bioinformatics tools
# Note: bwa-mem2 official releases are x86_64. 
# On ARM64, we will fall back to standard 'bwa' which is installed via conda.
RUN arch=$(uname -m) && \
    if [ "$arch" = "x86_64" ]; then \
        mkdir -p /opt/mitogex/Software/bwa-mem2 && \
        cd /opt/mitogex/Software/bwa-mem2 && \
        curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 | tar jxf - && \
        mv bwa-mem2-2.2.1_x64-linux/* . ; \
    else \
        echo "Skipping bwa-mem2 native binary for ARM64. Using conda-provided bwa instead." ; \
    fi

RUN mkdir -p /opt/mitogex/Software/gatk && \
    cd /opt/mitogex/Software/gatk && \
    wget -q https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip && \
    unzip -q gatk-4.6.0.0.zip && \
    mv gatk-4.6.0.0/* .

RUN mkdir -p /opt/mitogex/Software/picard && \
    cd /opt/mitogex/Software/picard && \
    wget -q https://github.com/broadinstitute/picard/releases/download/3.2.0/picard.jar

RUN mkdir -p /opt/mitogex/Software/haplogrep3 && \
    cd /opt/mitogex/Software/haplogrep3 && \
    arch=$(uname -m) && \
    if [ "$arch" = "x86_64" ]; then \
        wget -q https://github.com/genepi/haplogrep3/releases/download/v3.2.1/haplogrep3-3.2.1-linux.zip ; \
    else \
        wget -q https://github.com/genepi/haplogrep3/releases/download/v3.2.1/haplogrep3-3.2.1-linux-arm64.zip -O haplogrep3-3.2.1-linux.zip ; \
    fi && \
    unzip -q haplogrep3-3.2.1-linux.zip && \
    rm haplogrep3-3.2.1-linux.zip && \
    ./haplogrep3 trees

# Copy entrypoint script
COPY worker-entrypoint.sh /worker-entrypoint.sh
RUN chmod +x /worker-entrypoint.sh

CMD ["/worker-entrypoint.sh"]
