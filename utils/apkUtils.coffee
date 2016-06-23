config = require '../config'
execFile = require('child_process').execFile
_ = require 'underscore'

module.exports =
  parse: (filename, cb) ->
    apkInfo = {}
    parsePackageInfo filename, (err, packageInfo) ->
      return cb err if err
      _.extend apkInfo, packageInfo
      parseProjectInfo filename, (err, projectInfo) ->
        return cb err if err
        _.extend apkInfo, projectInfo
        parseSubProjectInfo filename, (err, subProjectInfo) ->
          return cb err if err
          apkInfo.projectid += '_' + subProjectInfo.subProjectid if subProjectInfo?.subProjectid
          cb null, apkInfo

parsePackageInfo = (filename, cb) ->
  execFile config.aapt, ['d', 'badging', filename], {maxBuffer: 1024 * 1024}, (err, result) ->
    return cb err if err or not result
    if m = result.match /package: name='([^']+)' versionCode='([^']+)' versionName='([^']+)'/
      packageName = m[1]
      versionCode = m[2]
      versionName = m[3]
    if m = result.match /application[-: ]+label[:=]'([^']+)'/
      applicationLabel = m[1]
    cb null, {packageName, versionCode, versionName, applicationLabel}

parseProjectInfo = (filename, cb) ->
  execFile config.aapt, ['d', 'xmltree', filename, 'AndroidManifest.xml'], {maxBuffer: 1024 * 1024}, (err, result) ->
    return cb err if err or not result
    if m = result.match /E: meta-data \(line=\d+\)\s+A: android:name\(0x[0-9a-f]+\)="FREEPAY_CHANNEL_ID" \(Raw: "FREEPAY_CHANNEL_ID"\)\s+A: android:value\(0x[0-9a-f]+\)="([^"]+)" \(Raw: "([^"]+)"\)/
      projectid = m[1]
    cb null, {projectid}

parseSubProjectInfo = (filename, cb) ->
  execFile config.aapt, ['l', filename], {maxBuffer: 1024 * 1024}, (err, result) ->
    return cb err if err or not result
    if result.match /META-INF\/channel\.dat/
      execFile config.unzip, ['-p', filename, 'META-INF/channel.dat'], {maxBuffer: 1024 * 1024}, (err, result) ->
        return cb() if err or not result
        cb null, {subProjectid: result}
    else
      cb()
