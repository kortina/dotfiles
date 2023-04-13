#!/usr/bin/env python3

# import os
# import sys

# import requests

# GITHUB_API_URL = "https://api.github.com"


# def create_gist(file_path, file_content):
#     # Build the data and headers for the API request
#     data = {
#         "description": os.path.basename(file_path),
#         "public": False,
#         "files": {os.path.basename(file_path): {"content": file_content}},
#     }
#     headers = {"Authorization": f'token {os.environ["GITHUB_API_TOKEN"]}'}

#     # Call the API to create the new gist
#     response = requests.post(f"{GITHUB_API_URL}/gists", json=data, headers=headers)
#     if response.status_code == 201:
#         return response.json()["id"]
#     else:
#         print(f"Error creating gist: {response.status_code}")
#         print(response.text)
#         sys.exit(1)


# def update_gist(gist_id, file_path, file_content):
#     # Build the data and headers for the API request
#     data = {"files": {os.path.basename(file_path): {"content": file_content}}}
#     headers = {"Authorization": f'token {os.environ["GITHUB_API_TOKEN"]}'}

#     # Call the API to update the existing gist
#     response = requests.patch(
#         f"{GITHUB_API_URL}/gists/{gist_id}", json=data, headers=headers
#     )
#     if response.status_code == 200:
#         return gist_id
#     else:
#         print(f"Error updating gist: {response.status_code}")
#         print(response.text)
#         sys.exit(1)


# def search_gists(query):
#     # Set up API endpoint and headers
#     url = f"{GITHUB_API_URL}/gists"
#     headers = {"Accept": "application/vnd.github.v3+json"}

#     # Search for gists with the given name
#     params = {"q": f"{query}+user:<your_username>"}
#     found_gist_id = None

#     while True:
#         response = requests.get(url, headers=headers, params=params)

#         # Parse the response to find the ID of the matching gist
#         if response.status_code == 200:
#             results = response.json()  # ["items"]
#             for gist in results:
#                 if gist["description"] == query:
#                     found_gist_id = gist["id"]
#                     break

#             # If we found the desired gist, exit the loop
#             if found_gist_id is not None:
#                 return found_gist_id

#             # If there are more pages of results, continue to the next page
#             next_page_url = None
#             for link in response.headers["Link"].split(","):
#                 if 'rel="next"' in link:
#                     next_page_url = link.strip().split(";")[0][1:-1]

#             print(f"next_page_url: {next_page_url}")
#             if next_page_url is not None:
#                 url = next_page_url
#             else:
#                 return None
#         else:
#             print(f"Error searching gists: {response.status_code}")
#             print(response.text)
#             sys.exit(1)


# def create_or_update_gist(file_path):
#     # Load the file contents
#     with open(file_path, "r") as f:
#         file_content = f.read()

#     # Search for an existing gist with the same name
#     gist_id = search_gists(os.path.basename(file_path))

#     # Create a new gist if one does not already exist
#     if gist_id is None:
#         gist_id = create_gist(file_path, file_content)
#         print(f"Created new gist '{os.path.basename(file_path)}' with ID '{gist_id}'")
#     # Update the existing gist if one exists
#     else:
#         gist_id = update_gist(gist_id, file_path, file_content)
#         print(
#             f"Updated existing gist '{os.path.basename(file_path)}' with ID '{gist_id}'"
#         )


# if __name__ == "__main__":
#     # Check for the required GitHub API token
#     if "GITHUB_API_TOKEN" not in os.environ:
#         print("Error: 'GITHUB_API_TOKEN' environment variable is not set")
#         sys.exit(1)

#     # Check for the required file path argument
#     if len(sys.argv) != 2:
#         print("Usage: gist_create_or_update.py [filename]")
#         sys.exit(1)

#     # Create or update the gist
#     create_or_update_gist(sys.argv[1])

####################################################################################################

import os
import sys

from github import Github, InputFileContent


# find first gist where description = f_basename
def find_gist(user, f_basename):
    for g in user.get_gists():
        print(g.description)
        if g.description == f_basename:
            return g
    return None


def create_or_update_gist(file_path):
    # Load the file contents
    with open(file_path, "r") as f:
        file_content = f.read()

    # Authenticate with GitHub and get the user
    g = Github(os.environ["GITHUB_API_TOKEN"])

    f_basename = os.path.basename(file_path)
    files = {f_basename: InputFileContent(file_content)}

    user = g.get_user()
    gist = find_gist(user, f_basename)

    m = ""
    if gist:
        m = "UPDATE"
        gist.edit(description=f_basename, files=files)
    else:
        m = "CREATE"
        gist = user.create_gist(public=False, files=files, description=f_basename)
    print(f"{m}: {f_basename} // {gist.id}\n{gist.html_url}")


if __name__ == "__main__":
    # Check for the required GitHub API token
    if "GITHUB_API_TOKEN" not in os.environ:
        print("Error: 'GITHUB_API_TOKEN' environment variable is not set")
        sys.exit(1)

    # Check for the required file path argument
    if len(sys.argv) != 2:
        print("Usage: gist_create_or_update.py [filename]")
        sys.exit(1)

    # Create or update the gist
    create_or_update_gist(sys.argv[1])
