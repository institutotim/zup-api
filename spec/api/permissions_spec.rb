require 'app_helper'

describe Permissions::API do
  describe 'groups permissions' do
    include_examples 'act as permissionable', 'groups', :group
  end

  describe 'services permissions' do
    include_examples 'act as permissionable', 'services', :service
  end
end
