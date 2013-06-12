path = require "path"
gitteh = require "gitteh"

module.exports = (app) ->
  class app.ApplicationController


    # GET /
    @index = (req, res) ->
      gitteh.openRepository path.join(__dirname, "../..", ".git"), (err, repo) =>
        repo.reference "HEAD", true, (err, ref) =>
          repo.commit ref.target, (err, commit) =>
            commit.tree (err, tree) =>
              displayTree = (repo, tree) ->
                str = "<ul>"
                for entry in tree.entries
                  str += "<li>#{entry.name} (#{entry.attributes})"
                  if entry.attributes == 16384
                    str += "/" #+ displayTree(repo.tree entry.id)
                str
              treeDisplay = displayTree repo, tree
              res.render 'index',
                view: 'index'
                err: err
                repo: repo
                ref: ref
                commit: commit
                tree: tree
                treeDisplay: treeDisplay

