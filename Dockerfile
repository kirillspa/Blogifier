FROM mcr.microsoft.com/dotnet/sdk:5.0 as build

# Install required packages
RUN mkdir /usr/share/man/man1/
RUN apt-get update && apt-get install -y openjdk-11-jdk

# Installing coverelet console and .net sonarscaner
ENV PATH="$PATH:/root/.dotnet/tools"
RUN dotnet tool install --global dotnet-sonarscanner && \
    dotnet tool install --global coverlet.console

# Copy source code
COPY ./ /opt/blogifier
WORKDIR /opt/blogifier

# Running Sonar scan
RUN dotnet sonarscanner begin \
    /k:"blogifier" \
    /d:sonar.host.url="http://host.docker.internal:9000" \
    /d:sonar.login="4ec08525728c3cc8d8146f798ed4b392cf1bb9f2" \
    /d:sonar.cs.opencover.reportsPaths=coverage.opencover.xml

# Compile source code
RUN dotnet restore -v m 
RUN dotnet build --no-restore --nologo
# Publish project to outputs folder
RUN dotnet publish ./src/Blogifier/Blogifier.csproj -o ./outputs

# Getting code coverage report
RUN coverlet /opt/blogifier/tests/Blogifier.Tests/bin/Debug/net5.0/Blogifier.Tests.dll --target "dotnet" --targetargs "test --no-build" --format opencover

# Finishing sonarscan
RUN dotnet sonarscanner end /d:sonar.login="4ec08525728c3cc8d8146f798ed4b392cf1bb9f2"


# Final Image
FROM mcr.microsoft.com/dotnet/aspnet:5.0 as run
EXPOSE 80
COPY --from=build /opt/blogifier/outputs /opt/blogifier/outputs
WORKDIR /opt/blogifier/outputs
ENTRYPOINT ["dotnet", "Blogifier.dll"]
