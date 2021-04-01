# Automatically Enforce least privilege with recommendations by GCP.  


GCP gives you recommendations on your IAM permissions.  Often users have too much privilege based on a 90 day look back window. This script will automatically apply the GCP IAM permissions recommended by google by REMOVING roles no longer needed by the user.   

# Example view from the console

<p align="center">
  <img src="https://cloud.google.com/iam/img/recommender-replace.png" width="350" title="hover text">
</p>
