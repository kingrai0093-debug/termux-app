FROM openjdk:17-jdk-slim

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

RUN apt-get update && apt-get install -y wget unzip lib32stdc++6 lib32z1 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $ANDROID_SDK_ROOT && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "ndk;25.1.8937393"

WORKDIR /app
COPY . .

RUN chmod +x gradlew && \
    ./gradlew assembleDebug --no-daemon

RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/* && \
    pip3 install aiohttp

EXPOSE 8080
CMD ["python3", "-c", "import os, glob, aiohttp, asyncio; from aiohttp import web; app=web.Application(); async def list(_): return web.Response(text='<html><body><h1>Termux APKs</h1>'+''.join(f'<a href=\"{f}\">{f}</a><br>' for f in glob.glob('**/*.apk',recursive=True))+'</body></html>'); app.router.add_get('/',list); web.run_app(app,port=8080)"]
