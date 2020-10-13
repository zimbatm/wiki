I see a lot of users out there that don't understand the Git staging area.

Conceptually this is the biggest change between traditional Source Control Management (SCM) tools and Git. Tutorials should explain that first:

Traditional SCM: code changes -> commit
Git: code changes -> staging area -> commit

To understand Git, the important part is to form that mental model. The code changes don't go to a commit directly. Instead, they are put in that staging area. That area is a virtual place where all the changes get accumulated. When typing `git commit`, the changes are moved from that area into the commit.

A user who doesn't have that mental model will find the Git tooling confusing. This feature both provides more flexibility, and makes all the CLI interfaces more complicated to use.

Here is how I translate a number of commands mentally:

* `git add somefile`: add the changes in "somefile" into the staging area
* `git add -p`: selectively add changes to the staging area.
* `git commit -a`: add all the changes of the tracked files into the staging area, and then create a commit from it.

Hope this helps,
z