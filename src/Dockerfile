FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Using the focal image to build due to the issues with SSL and nuget until microsoft updates their images
FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /SuperService
COPY ["src/SuperService.csproj", "src/"]
RUN dotnet restore "src/SuperService.csproj"
COPY . .
WORKDIR "/SuperService/src"
RUN dotnet build "SuperService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SuperService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SuperService.dll"]