<div id="top"></div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="https://www.syntho.ai/wp-content/uploads/2021/03/cropped-Syntho_logo_wide.png" alt="Logo" height="80">
  </a>

<h3 align="center">Syntho Charts</h3>

  <p align="center">
    General repository for Syntho Helm charts and other related configuration files.
    <br />
    <a href="https://github.com/syntho-ai/syntho-docs"><strong>Explore the deployment docs »</strong></a>
    <br />
    <br />
  </p>
</div>

<!-- ABOUT THE PROJECT -->

## About The Project

A repository containing all the relevant Helm charts and other related configuration files for the Syntho applications. Under the folder `/helm`, the following Helm charts are available:

- Ray (Chart + sample configuration)
- JupyterHub (only sample configuration)
- Syntho Application (Chart)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->

### Getting all images as .tar files locally

Script `prepare-syntho-images.sh` has been prepared for convenience for a case where target enviroment does not have an access to internet. Script will save all images into single `syntho-images.tar` file (save mode), which can be moved to target machine and loaded there with the same script (load mode).

#### Usage
`/prepare-syntho-images.sh --mode <save/load> --tag <tag> --path <path>`

#### Example saving images to local .tar file:

`/prepare-syntho-images.sh --mode save --tag latest --path /home/syntho/images`

#### Example loading images to local .tar file:

`/prepare-syntho-images.sh --mode load --tag latest --path /home/syntho/images`

## Contact

Syntho - info@syntho.ai

<p align="right">(<a href="#top">back to top</a>)</p>
