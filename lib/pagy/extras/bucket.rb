require 'pagy/bucket'
require 'pagy/extras/bootstrap'

class Pagy # :nodoc:
  #
  module BucketExtra
    #
    module Backend
      CONF_KEYS = %i[pagy buckets].freeze

      private

      def pagy_bucket(collection, conf)
        unless conf.is_a?(Hash) && (conf.keys - CONF_KEYS).empty?
          raise ArgumentError, "keys must be in #{CONF_KEYS.inspect}; got #{conf.inspect}"
        end

        vars = pagy_get_vars(collection, conf)
        vars[:buckets] ||= collection.keys.sort
        vars[:count] = vars[:buckets].length

        pagy = Pagy::Bucket.new(vars)

        [pagy, pagy_bucket_filter(collection, pagy.page)]
      end

      def pagy_bucket_filter(collection, bucket_key)
        raise NoMethodError, 'the pagy_bucket_filter method must be implemented by the application'
      end
    end

    module Frontend
      def pagy_bucket_bootstrap_nav(pagy, pagy_id: nil, link_extra: '', **vars)
        p_id = %( id="#{pagy_id}") if pagy_id
        link = pagy_link_proc(pagy, link_extra: %(class="page-link" #{link_extra}))

        html = +%(<nav#{p_id} class="pagy-bootstrap-nav" aria-label="pager"><ul class="pagination">)
        html << pagy_bootstrap_prev_html(pagy, link)
        pagy.series(**vars).each do |item| # series example: [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
          html << if item == pagy.page
                    %(<li class="page-item active">#{link.call item}</li>)
                  elsif item == :gap
                    %(<li class="page-item gap disabled"><a href="#" class="page-link">#{pagy_t 'pagy.nav.gap'}</a></li>)
                  else
                    %(<li class="page-item">#{link.call item}</li>)
                  end
        end
        html << pagy_bootstrap_next_html(pagy, link)
        html << %(</ul></nav>)
      end
    end
  end

  Backend.prepend BucketExtra::Backend
  Frontend.prepend BucketExtra::Frontend
end
