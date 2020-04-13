# The MIT License (MIT)

# Copyright (c) 2020 wanyakun

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "YKBIU/version"

module Pod
  class Podfile

    # 从url获取依赖并进行依赖安装
    #
    # @param url 获取依赖配置的请求url
    # @param params 获取依赖配置的请求参数
    # @param method 获取依赖配置的请求方式
    # @param ignores 依赖安装忽略列表，默认为空
    #
    def makeup_pods(url, params, method, ignores = [])
      UI.title "makeup pods dependency from #{url}"
      file = "dependency.json"
      dependencies = peform_request(url, params, method)
      if dependencies
        #1.保存json
        File.delete(file) if File.exist?(file)
        File.open(file, "w") { |io|  io.syswrite(JSON.generate(dependencies))}
        #2.安装依赖
        yk_pod(dependencies, ignores)
      else
        #1.读取本地保存的json
        json = File.read(file) if File.exist?(file)
        dependencies = JSON.parse(json)
        #2.安装依赖
        yk_pod(dependencies, ignores) if dependencies
      end
    end

    # 安装依赖，在安装依赖的过程中判断是否在ignores中，
    # 如果在ignores中则忽略不进行依赖安装，
    # 如果不在ignores，判断是否有componentVersion，优先是用版本进行安装，否则进行url、tag、commit等配置进行安装依赖
    #
    # @param dependencies 依赖列表
    # @param ignores 忽略列表
    #
    def yk_pod(dependencies, ignores)
      dependencies.each { |value|
        componentName = value.fetch("dependencyName", nil)
        # 忽略组件名称不存的依赖
        return unless componentName
        # 跳过在ignores列表中的依赖
        next if ignores.include? componentName

        version = value.fetch("componentVersion", nil)
        if version
          pod(componentName, version)
        else
          hash = {}
          value.each{ |rKey, rValue|
            hash[:git] = rValue if rKey == "gitUrl"
            hash[:branch] = rValue if rKey == "componentBranch"
            hash[:tag] = rValue if rKey == "tag"
            hash[:commit] = rValue if rKey == "commit"
            hash[:configuration] = rValue if rKey == "configuration"
            hash[:path] = rValue if rKey == "path"
            hash[:podspec] = rValue if rKey == "podspec"
            hash[:subspecs] = rValue if rKey == "subspecs"
          }
          pod(componentName, hash)
        end
      }
    end

    # 处理获取依赖的网络请求
    #
    # @param url 请求的url
    # @param paras 请求的参数
    # @param method 请求的方式
    #
    def peform_request(url, params, method)
      require 'rest'
      require 'json'

      headers = {'Accept' => 'application/json, */*', 'Content-Type' => 'application/json; charset=utf-8'}
      if 'GET' == method || 'get' == method
        response = REST.get(url, headers, params)
        handleResponse(url, response)
      elsif 'POST' == method || 'post' == method
        response = REST.post(url, params.to_json, headers)
        handleResponse(url, response)
      end
    end

    # 处理网络请求返回来的内容
    #
    # @param response 应返回json数据结构，如下：
    #
    # {
    #   "result": 0,
    #   "codeMsg": "",
    #   "resultMessage": "响应成功",
    #   "content": [
    #     {
    #       "dependencyName": "AFNetworking",
    #       "componentVersion": "~> 3.2.0"
    #     }
    #      ]
    #   }
    #
    def handleResponse(url, response)
      if response.ok?
        body = JSON.parse(response.body)
        result = body["result"]
        if result == 0
          content = body["content"]
          UI.title content
          content
        else
          resultMessage = body["resultMessage"]
          CoreUI.warn "Request to #{url} has error - #{resultMessage}"
          nil
        end
      else
        CoreUI.warn "Request to #{url} failed - #{response.status_code}"
        nil
      end
    end
  end
end
