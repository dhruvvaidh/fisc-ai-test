# Project Workflow and Development Guidelines
This document outlines our branching strategy, development workflow, and setup instructions to ensure a smooth collaboration process.

To ensure everyone is on the same page and has a functioning deployable form of the website, please have Amplify installed on your machines. DO NOT PUSH or merge big changes directly; instead, make pull requests for any updates.

## Branch Structure

Our project utilizes the following branches:

- **main**: Contains the stable and agreed-upon codebase. This branch should remain untouched except for merging finalized updates from other branches. DO NOT PUSH ANYTHING TO MAIN, make pull requests from your own branches.
- **amplify_branch**: Managed primarily by Manas, this branch is used for iterative development and sandbox testing related to AWS Amplify integrations.
- **terraform**: Dedicated to infrastructure provisioning using Terraform, this branch is actively developed by Devang and Leo.

## Development Workflow

To maintain code quality and facilitate integration, please adhere to the following workflow:

1. **Create a New Branch**: For any new feature or bug fix, create a dedicated branch from the `main` branch.

   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Develop and Commit**: Make your changes in your branch and commit them regularly.

   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

3. **Push to Remote**: Push your branch to the remote repository.

   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request**: Once your feature or fix is complete, create a pull request to merge your branch into `main`.

   ### Pull Request Steps

   1. Go to the repository on GitHub.
   2. Click on the "Pull requests" tab.
   3. Click the "New pull request" button.
   4. Select the branch you want to merge into `main`.
   5. Provide a clear title and description for your pull request.
   6. Request reviews from your team members.
   7. Address any feedback and make necessary changes.
   8. Once approved, merge the pull request.

## AWS Amplify Setup

Ensure that you have configured Amplify Gen1. Follow the [AWS Amplify Setup Guide](https://docs.amplify.aws/start/getting-started/installation/q/integration/react) to set up your environment. This will allow you to host your version of the web app on the cloud.

## Project Structure

- **fisc-ai/frontend**: Contains the frontend React code.
- **fisc-ai/python**: Contains the Python backend code.

By following these guidelines, we can ensure a smooth and efficient development process. Happy coding!
