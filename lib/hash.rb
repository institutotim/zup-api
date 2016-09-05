class Hash
  def merge_if_not_nil(params)
    params = params.delete_if { |_k, v| v.nil? }
    merge(params)
  end
end
