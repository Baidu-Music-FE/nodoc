_ = require 'lodash'

rule =
    commentReg: /###\*([\s\S]+?)###\s+([\w\.]+)/g
    splitReg: /^\s+\* ?@/m
    tagNameReg: /^([\w\.]+)\s*/
    typeReg: /^\{(.+?)\}\s*/
    nameReg: /^(\w+)\s*/
    nameTags: ['param', 'property']
    descriptionReg: /^([\s\S]*)/

parseContent = (content, r) ->
    # Unescape '\/'
    content = content.replace /\\\//g, '/'

    # Clean the prefix '*'
    arr = content.split(r.splitReg).map (el) ->
        el.replace(/^[ \t]+\*[ \t]?/mg, '').trim()

    description: arr[0] or ''
    tags: arr[1..].map (el)->
        parseTag = (reg) ->
            m = el.match reg
            if m and m[1]
                el = el[m[0].length..]
                m[1]
            else
                null

        tag = {}

        tag.tagName = parseTag r.tagNameReg
        type = parseTag r.typeReg

        if type
            tag.type = type.trim()
            if tag.tagName in r.nameTags
                tag.name = parseTag r.nameReg

        tag.description = parseTag(r.descriptionReg) or ''

        tag

parse = (source, localRule = {})->
    r = _.defaults localRule, rule

    comments = []
    while m = r.commentReg.exec source
        content = parseContent m[1], r
        lastIndex = r.commentReg.lastIndex
        comments.push
            name: m[2]
            description: content.description
            tags: content.tags
            line: source[...lastIndex].split('\n').length - 1
    comments

module.exports =
    parse: parse
    setRule: (ruleObj)->
        _.assign rule, ruleObj