FROM instrumentisto/flutter

# Install Android dependencies.
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    file \
    git \
    libglu1-mesa \
    libqt5widgets5 \
    && rm -rf /var/lib/apt/lists/*

# Pre-download development binaries.
RUN flutter precache

# Install additional SDK tools.
RUN sdkmanager --update
RUN sdkmanager "platforms;android-31" "build-tools;30.0.3"

# Set the working directory.
WORKDIR /app

# No entrypoint. Usually, you'll want to run bash
# (at the least to run 'adb connect ...' first).
ENTRYPOINT []
