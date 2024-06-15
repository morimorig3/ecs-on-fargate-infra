resource "aws_cloudfront_distribution" "corperate_cloudfront" {
  origin {
    domain_name = aws_lb.this.name
    origin_id   = aws_lb.this.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2" # デフォルトのhttp2を明示的に指定。
  comment             = "corperate_cloudfront"

  # distribution用のCNAME
  # Route53でCloudFrontのエイリアスを設定する場合、この値とレコードがが等しくなる必要がある。
  aliases = ["bita.jp"]

  # Errorレスポンスのカスタマイズ設定。
  custom_error_response {
    error_caching_min_ttl = 300 # デフォルトの5分間を明示的に指定。
    error_code            = 500 # カスタマイズしたいエラーコードを指定する。
    response_code         = 200 # Viewerに返したいコードを指定する。
    response_page_path    = "/custom_404.html"
  }

  # キャッシュのデフォルト設定。
  default_cache_behavior {
    allowed_methods = ["HEAD", "GET", "PUT", "POST", "DELETE", "PATCH"] # CloudFrontで許可するメソッド。
    cached_methods  = ["HEAD", "GET"]                                   # キャッシュするメソッド。
    compress        = true                                              # 高速化のためコンテンツ圧縮(gzip)を許可する。
    # Cache-Control or Expires がリクエストのヘッダーに無い時のデフォルトのTTL。
    default_ttl            = 86400               # デフォルトの1日を明示的に指定。
    viewer_protocol_policy = "redirect-to-https" # HTTPS通信のみ許可する。
    target_origin_id       = aws_lb.this.id


    max_ttl = 31536000 # デフォルトの365日を明示的に指定。
    min_ttl = 0        # デフォルトの0sを明示的に指定。

    # 転送する時にCookie等の扱い方の設定。
    forwarded_values {
      query_string = false # クエリ文字の設定。今回使用しないため無効。
      cookies {
        forward = "none" # 全てのCookieを転送する。
        # whitelisted_names = [] # whitelistの場合に設定する必要がある。
      }
    }
  }

  # アクセスログ設定
  logging_config {
    bucket          = aws_s3_bucket.cloudfront_log_bucket.bucket_domain_name
    include_cookies = true # Cookieもアクセスログに含めたいため有効。
    prefix          = "cloudfront/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = [] # blacklist(or whitelist)の対象を設定していく。
    }
  }
  # TODO SSL証明書の設定
  # SSL証明書の設定
  viewer_certificate {
    # cloudfront_default_certificate = false # ACMで作成した証明書を使用するため無効。
    # acm_certificate_arn            = "arn:aws:acm:us-east-1:XXXXXXXXXXXXXX:certificate/XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    # minimum_protocol_version       = "TLSv1.2_2019" # SSLの最小バージョン。AWSの推奨値を採用。
    # # SNI(名前ベース)のSSL機能を使用する。
    # # https://aws.amazon.com/jp/cloudfront/custom-ssl-domains/
    # ssl_support_method = "sni-only"
  }

}
