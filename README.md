~~ Version Control (Git) ~~

Please work on the 'dev' branch. Any features, which might break dev, should be developed on a separate branch:
$ git checkout -b feat/myfeature dev

and later merged back into dev:
$ git checkout dev
$ git merge --no-ff feat/myfeature

deleting the branch:
$ git branch -d feat/myfeature

For more detail, please see http://nvie.com/posts/a-successful-git-branching-model/