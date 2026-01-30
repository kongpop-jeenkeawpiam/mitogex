# Dockerfile for MitoGEx
FROM continuumio/miniconda3:24.7.1-0

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    MITOGEX_DIR=/opt/mitogex \
    PATH=/opt/mitogex/Software/bwa-mem2:/opt/mitogex/Software/gatk:/opt/mitogex/Software/haplogrep3:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-jre \
    default-jdk \
    build-essential \
    jq \
    iqtree \
    r-base-core \
    curl \
    wget \
    unzip \
    bc \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgl1-mesa-glx \
    libglx-mesa0 \
    libgl1-mesa-dri \
    mesa-utils \
    x11-apps \
    xvfb \
    libgtk-3-0 \
    libgtk-3-dev \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    libatk1.0-0 \
    libxtst6 \
    libxi6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq

# Set working directory
WORKDIR ${MITOGEX_DIR}

# Copy project files
COPY mitogex.yml mitogex_ete.yml ./
COPY src ./src
COPY *.sh ./
COPY MitoGEx-1.0.jar ./
COPY README.md LICENSE ./

# Accept conda terms of service
RUN conda config --set channel_priority flexible && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --add channels etetoolkit

# Create conda environments
RUN conda env create -f mitogex_ete.yml && \
    conda env create -f mitogex.yml && \
    conda clean -afy

# Initialize conda for bash
RUN conda init bash && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate mitogex" >> ~/.bashrc

# Install R packages in mitogex environment
RUN /bin/bash -c "source activate mitogex && \
    Rscript -e 'if (!require(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"gsmoothr\", repos=\"http://R-Forge.R-project.org\")' && \
    R --slave -e 'BiocManager::install(version = \"3.19\", ask=FALSE)' && \
    R --slave -e 'BiocManager::install(\"Repitools\", force=TRUE)'"

# Run ete3 build check in mitogex_ete environment
RUN /bin/bash -c "source activate mitogex_ete && ete3 build check"

# Install bwa-mem2
RUN mkdir -p ${MITOGEX_DIR}/Software/bwa-mem2 && \
    cd ${MITOGEX_DIR}/Software/bwa-mem2 && \
    curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 | tar jxf - && \
    mv bwa-mem2-2.2.1_x64-linux/* . && \
    rm -rf bwa-mem2-2.2.1_x64-linux

# Install GATK 4.6
RUN mkdir -p ${MITOGEX_DIR}/Software/gatk && \
    cd ${MITOGEX_DIR}/Software/gatk && \
    wget -q https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip && \
    unzip -q gatk-4.6.0.0.zip && \
    mv gatk-4.6.0.0/* . && \
    rm -rf gatk-4.6.0.0 gatk-4.6.0.0.zip

# Install Picard
RUN mkdir -p ${MITOGEX_DIR}/Software/picard && \
    cd ${MITOGEX_DIR}/Software/picard && \
    wget -q https://github.com/broadinstitute/picard/releases/download/3.2.0/picard.jar

# Install Haplogrep3
RUN mkdir -p ${MITOGEX_DIR}/Software/haplogrep3 && \
    cd ${MITOGEX_DIR}/Software/haplogrep3 && \
    wget -q https://github.com/genepi/haplogrep3/releases/download/v3.2.1/haplogrep3-3.2.1-linux.zip && \
    unzip -q haplogrep3-3.2.1-linux.zip && \
    rm haplogrep3-3.2.1-linux.zip && \
    ./haplogrep3 trees && \
    chmod -R 777 trees/

# Install haplocheckCLI
RUN mkdir -p ${MITOGEX_DIR}/Software/mtdnaserver && \
    cd ${MITOGEX_DIR}/Software/mtdnaserver && \
    wget -q https://github.com/leklab/haplocheckCLI/raw/master/haplocheckCLI.jar

# Install ANNOVAR
RUN mkdir -p ${MITOGEX_DIR}/Software && \
    cd ${MITOGEX_DIR}/Software && \
    wget -q http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz && \
    tar -xzf annovar.latest.tar.gz && \
    rm annovar.latest.tar.gz && \
    mkdir -p annovar/humandb

# Install Cromwell
RUN cd ${MITOGEX_DIR}/Software && \
    wget -q https://github.com/broadinstitute/cromwell/releases/download/87/cromwell-87.jar

# Download MitImpact Database
RUN wget -q https://mitogex.com/database/annovar/hg38_MitImpact313.txt -O \
    ${MITOGEX_DIR}/Software/annovar/humandb/hg38_MitImpact313.txt || \
    echo "Warning: MitImpact database download failed (may require authentication)"

# Download scripts
RUN cd ${MITOGEX_DIR} && \
    wget -q https://mitogex.com/scripts2/scripts.zip && \
    unzip -q scripts.zip -d ${MITOGEX_DIR}/Software/ && \
    rm scripts.zip || \
    echo "Warning: Scripts download failed"

# Disable auto-update (no-op update.sh)
RUN printf '#!/bin/bash\nexit 1\n' > ${MITOGEX_DIR}/Software/scripts/update.sh && \
    chmod +x ${MITOGEX_DIR}/Software/scripts/update.sh

# Download lib.zip
RUN cd ${MITOGEX_DIR} && \
    wget -q https://mitogex.com/lib.zip && \
    unzip -q lib.zip && \
    rm lib.zip || \
    echo "Warning: lib.zip download failed"
    

# Create directories for volumes
RUN mkdir -p ${MITOGEX_DIR}/Software/file_log \
             ${MITOGEX_DIR}/.cache \
             ${MITOGEX_DIR}/.config \
             ${MITOGEX_DIR}/.java \
             /tmp/runtime-root && \
    touch ${MITOGEX_DIR}/local_versions.txt \
          ${MITOGEX_DIR}/update.log && \
    chmod -R 777 ${MITOGEX_DIR} \
                 /tmp/runtime-root
                 
# Make scripts executable (don't change other permissions)
RUN if [ -d ${MITOGEX_DIR}/Software/scripts ]; then chmod +x ${MITOGEX_DIR}/Software/scripts/*.sh; fi && \
    chmod +x ${MITOGEX_DIR}/*.sh

# Create entrypoint script with proper conda setup
RUN printf '#!/bin/bash\n\
if [ -f /opt/conda/etc/profile.d/conda.sh ]; then\n\
    . /opt/conda/etc/profile.d/conda.sh\n\
    conda activate mitogex 2>/dev/null || true\n\
fi\n\
exec "$@"\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Create wrapper script for GUI with Xvfb
RUN printf '#!/bin/bash\n\
# Start Xvfb in background\n\
echo "Starting virtual display..."\n\
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &\n\
XVFB_PID=$!\n\
export DISPLAY=:99\n\
\n\
# Wait for X server to be ready\n\
for i in {1..10}; do\n\
    if xdpyinfo -display :99 >/dev/null 2>&1; then\n\
        echo "Display :99 is ready"\n\
        break\n\
    fi\n\
    echo "Waiting for display... ($i/10)"\n\
    sleep 1\n\
done\n\
\n\
# Execute the command\n\
exec "$@"\n' > /start-gui.sh && \
    chmod +x /start-gui.sh

# Expose display for X11
ENV QT_X11_NO_MITSHM=1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD conda run -n mitogex python --version || exit 1

