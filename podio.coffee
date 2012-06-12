
http = require "https"

class Podio
        _send_request: (path, method="GET", content=undefined, on_success_cb, on_error_cb) ->
                content = JSON.stringify(content) if typeof(content) != "string"

                options =
                        host: if path.match("/oauth") then "podio.com" else "api.podio.com"
                        port: 443
                        path: path
                        method: method
                        headers:
                             'Content-Length': content.length
                             'Content-Type': 'application/json'

                options.headers.Authorization = "OAuth2 " + @token if @token?
                req = http.request options, (res) =>
                        return on_error_cb() unless res.statusCode == 200
                res.on "data", (chunk) =>
                        data = JSON.parse(chunk)
                        on_success_cb(data)

                req.on "error", (e) =>
                        on_error_cb()

                req.write(content) unless method == "GET"
                req.end()


        authenticate: (callback) ->
                ###
                Authenticate with Podio
                ###
                username = process.env.PODIO_USERNAME
                password = process.env.PODIO_PASSWORD
                client_id = process.env.PODIO_CLIENT_ID
                client_secret = process.env.PODIO_CLIENT_SECRET
                redirect_url = process.env.PODIO_URL
                path =  "/oauth/token?grant_type=password&username=#{username}&password=#{password}&client_id=#{client_id}&redirect_uri=#{redirect_url}&client_secret=#{client_secret}"
                auth_success_cb = (data) =>
                @token = data.access_token
                callback()

                @_send_request path, "POST", '', auth_success_cb, =>
                        console.log "Error while authenticating"

        update_item: (item_id, data, success_cb, error_cb) =>
                @authenticate =>
                        path = "/item/#{item_id}"
                        @_send_request path, "PUT", data, success_cb, error_cb

        comment: (item_id, data, success_cb, error_cb) =>
                @authenticate =>
                        path = "/comment/item/#{item}"
                        @_send_request path, "POST", data, success_cb


