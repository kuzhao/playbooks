FROM mcr.microsoft.com/windows/servercore:ltsc2019
WORKDIR /azp

COPY git-install.inf .
COPY git.ps1 .
RUN powershell .\git.ps1

COPY vsbuildtools.ps1 .
RUN powershell .\vsbuildtools.ps1

COPY start.ps1 .
CMD powershell .\start.ps1
