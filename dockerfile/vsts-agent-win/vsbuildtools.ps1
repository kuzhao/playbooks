# Download the Build Tools bootstrapper.
$wc = New-Object System.Net.WebClient
$wc.DownloadFile("https://aka.ms/vs/17/release/vs_buildtools.exe", "vs_buildtools.exe")

# Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
.\vs_buildtools.exe --quiet --wait --norestart --nocache --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Component.VSSDKBuildTools --add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.NuGet.BuildTools
