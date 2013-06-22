path = require "path"
gitteh = require "gitteh"
async = require "async"

module.exports = (app) ->
  class app.ApplicationController

    app.aggregateTreeEntries = (arr, repo, tree, cb) ->
      entryHandler = (entry, next) ->
        ret =
          name: entry.name
          dir: entry.attributes == 16384
          children: []
        arr.push ret
        console.log arr
        if ret.dir
          console.log "Recursing into #{ret.name}"
          repo.tree entry.id, (err, t) => app.aggregateTreeEntries ret.children, repo, t,
            (err) -> next()
        else
          next()
      async.each tree.entries, entryHandler, (err) -> cb(arr) if cb

    # GET /
    @index = (req, res) ->
      gitteh.openRepository path.join(__dirname, "../..", ".git"), (err, repo) =>
        repo.reference "HEAD", true, (err, ref) =>
          repo.commit ref.target, (err, commit) =>
            commit.tree (err, tree) =>
              app.aggregateTreeEntries [], repo, tree, (entries) ->
                console.log entries
                res.render 'index',
                  view: 'index'
                  err: err
                  repo: repo
                  ref: ref
                  commit: commit
                  tree: tree
                  entries: entries

