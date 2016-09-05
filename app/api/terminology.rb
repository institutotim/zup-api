module Terminology
  class API < Base::API
    helpers do
      def adds_to_hash(hash, term, content, namespace = [])
        if content.is_a?(Hash)
          content.each do |content_term, content_content|
            adds_to_hash(hash, content_term, content_content, namespace + [term])
          end
        else
          term_label = ''

          if namespace.any?
            term_label = namespace.map(&:upcase).join('_')
            term_label += '_'
          end

          term_label += term.upcase

          hash[term_label] = I18n.t(
            term, scope: ([:terminology] + namespace),
            default: I18n.t(term, scope: ([:default_terminology] + namespace))
          )
        end

        hash
      end
    end

    desc 'Get all the correct terminology'
    get '/terminology' do
      terms = YAML.load(
        File.read(File.join(Application.config.root, 'config', 'locales', "#{I18n.locale}.yml"))
      )['pt-BR']['default_terminology']

      terms.reduce({}) do |hash, (term, content)|
        adds_to_hash(hash, term, content)
      end
    end
  end
end
