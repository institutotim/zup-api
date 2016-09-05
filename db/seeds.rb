# encoding: utf-8
#
# ####################################
# # !!!!! IMPORTANT !!!!!            #
# ####################################
#
# This should be a safe file in production environments,
# if the WITH_FAKE_DATA environment variable is unset.
#
# So, ALWAYS ensure that outside the WITH_FAKE_DATA if checking
# you're ensuring that you're not messing around with data without
# need.

require 'ffaker'
require 'faker/cpf'
require 'cpf_faker'
require 'factory_girl'

fg = FactoryGirl
fg.find_definitions

# Helper methods
def build_options_for_field(field, options)
  options.each do |option_value|
    field.field_options.build(
      FactoryGirl.attributes_for(:inventory_field_option, field: field, value: option_value)
    )
  end
end

## Create global namespace
namespace = Namespace.first_or_create(name: 'Global', default: true)

## Create groups--rm \
if Group.count == 0
  guest_group = fg.create(:guest_group, name: 'Público', namespace: namespace)
  admin = fg.create(:group_for_admin, name: 'Administradores', namespace: namespace)
  Rake::Task['groups:migrate_permissions'].invoke
else
  guest_group = Group.unscoped.guest.where(namespace: namespace).first
  admin = Group.unscoped.find_by(name: 'Administradores', namespace: namespace)
end

## Create settings
unless Setting.exists?(name: 'reports_listing_columns')
  Setting.create_with(
    value: [
      { id: nil, type: 'protocol', label: 'Protocolo', active: true },
      { id: nil, type: 'priority', label: 'Prioridade', active: true },
      { id: nil, type: 'address', label: 'Endereço', active: true },
      { id: nil, type: 'user', label: 'Solicitante', active: true },
      { id: nil, type: 'reporter', label: 'Criador', active: true },
      { id: nil, type: 'category', label: 'Categoria', active: true },
      { id: nil, type: 'assignment', label: 'Atribuído á', active: true },
      { id: nil, type: 'created_at', label: 'Data de inclusão', active: true }
    ]
  ).find_or_create_by(
    name: 'reports_listing_columns'
  )
end

flags = %w(
  explore
  create_report_clients
  create_report_panel
  stats
  social_networks_facebook
  social_networks_twitter
  social_networks_gplus
  allow_photo_album_access
  cases
  inventory
  reports
  show_resolution_time_to_clients
  show_answer_to_requester
)

flags.each do |flag|
  FeatureFlag.create_with(status: :enabled)
             .find_or_create_by(name: flag)
end

# Functional admin
unless User.find_by(email: 'admin@zeladoriaurbana.com.br')
  admin_email = 'admin@zeladoriaurbana.com.br'
  password = ENV['ADMIN_PASSWORD'] || SecureRandom.hex[0..8]
  fg.create(:user, email: admin_email, password: password, groups: [admin], namespace: namespace)

  puts '******************************************************************'
  puts "Administrator email: #{admin_email}"
  puts "Administrator password: #{password}"
  puts '******************************************************************'
end

if ENV['WITH_FAKE_DATA'] == 'true'
  ## Users
  # Common Users
  users = fg.create_list(:user, 100, groups: [guest_group], namespace: namespace)

  # Admins
  admins = fg.create_list(:user, 10, groups: [admin], namespace: namespace)

  ## Create inventory categories
  arvores = fg.create(
      :inventory_category_with_sections, title: 'Árvores',
      color: '#78c953'
  )
  bocas_de_lobo = fg.create(
      :inventory_category_with_sections, title: 'Bocas de Lobo',
      color: '#2ab4dc'
  )
  pracas_wifi = fg.create(
      :inventory_category_with_sections, title: 'Praças Wifi',
      color: '#ff6049'
  )

  arvores_icon = File.open(File.join(Application.config.root, 'public', 'base', 'default_icons', 'icon_arvore@2x.png'))
  arvores.update!(
      icon: arvores_icon,
      marker: arvores_icon,
      pin: arvores_icon
  )
  bocas_de_lobo_icon = File.open(File.join(Application.config.root, 'public', 'base', 'default_icons', 'icon_bocalobo@2x.png'))
  bocas_de_lobo.update!(
      icon: bocas_de_lobo_icon,
      marker: bocas_de_lobo_icon,
      pin: bocas_de_lobo_icon
  )
  wifi_icon = File.open(File.join(Application.config.root, 'public', 'base', 'default_icons', 'icon_pracawifi@2x.png'))
  pracas_wifi.update!(
      icon: wifi_icon,
      marker: wifi_icon,
      pin: wifi_icon
  )
  entulhos_icon = File.open(File.join(Application.config.root, 'public', 'base', 'default_icons', 'icon_coletaentulho@2x.png'))

  ## Modify forms
  section = arvores.sections.build(title: 'Outros dados')

  section.fields.build(
      title: 'return_condition',
      position: 0,
      kind: 'text',
      label: 'Condição do Retorno'
  )

  section.fields.build(
      title: 'pavimento',
      position: 1,
      kind: 'text',
      label: 'Levantamento do Pavimento'
  )

  section.fields.build(
      title: 'angle_direction',
      position: 2,
      kind: 'text',
      label: 'Direção da Inclinação'
  )

  section.fields.build(
      title: 'extra_vegetation',
      position: 3,
      kind: 'text',
      label: 'Vegetação interferente'
  )

  field = section.fields.build(
      title: 'angle_inclination',
      position: 4,
      kind: 'text',
      label: 'Inclinação tronco'
  )

  build_options_for_field(field, ['Menor que 45', 'Entre 45 e 75', 'Superior à 90'])

  field = section.fields.build(
      title: 'leafs_interference',
      position: 5,
      kind: 'radio',
      label: 'Interferência na copa'
  )

  build_options_for_field(field, ['Sim', 'Não'])

  section.save!

  section = bocas_de_lobo.sections.build(title: 'Outros dados')

  section.fields.build(
      title: 'depth',
      position: 0,
      kind: 'text',
      label: 'Profundidade'
  )
  section.fields.build(
      title: 'type',
      position: 1,
      kind: 'text',
      label: 'Tipo de Tampa'
  )

  section = pracas_wifi.sections.build(title: 'Outros dados')

  section.fields.build(
      title: 'max_number_of_conections',
      position: 0,
      kind: 'text',
      label: 'Número máximo de conexões'
  )
  section.fields.build(
      title: 'wifi_password',
      position: 1,
      kind: 'text',
      label: 'Senha do Wifi'
  )

  ## Create inventory categories items
  arvores_items = boca_de_lobo_items = pracas_wifi_items = []
  500.times do
    arvores_items << fg.create(:inventory_item, category: arvores, user: users.sample)
    boca_de_lobo_items << fg.create(:inventory_item, category: bocas_de_lobo, user: users.sample)
    pracas_wifi_items << fg.create(:inventory_item, category: pracas_wifi, user: users.sample)
  end

  ## Create reports categories
  limpeza_de_boca = fg.create(:reports_category_with_statuses, title: 'Limpeza de Boca', color: bocas_de_lobo.color)
  coleta_de_entulho = fg.create(:reports_category_with_statuses, title: 'Coleta de Entulho', color: '#ffac2d')

  limpeza_de_boca.update!(
    marker: bocas_de_lobo_icon,
    icon: bocas_de_lobo_icon,
    solver_groups_ids: [admin.id],
    default_solver_group_id: admin.id
  )
  coleta_de_entulho.update!(
    marker: entulhos_icon,
    icon: entulhos_icon,
    solver_groups_ids: [admin.id],
    default_solver_group_id: admin.id
  )

  # Association reports categories to inventory categories
  limpeza_de_boca.inventory_categories << bocas_de_lobo

  ## Create reports items for categories
  Reports::Item.skip_callback('create', :after, :send_email_to_user)
  1000.times do |i|
    created_at = i.days.from_now

    if i > 50
      created_at += 1.year
    end

    fg.create(:reports_item, inventory_item: boca_de_lobo_items.sample, category: limpeza_de_boca, created_at: created_at, user: users.sample, reporter: users.sample)
    fg.create(:reports_item, category: coleta_de_entulho, created_at: i.days.from_now, user: users.sample, reporter: users.sample)
  end

  # Balance the reports items statuses
  statuses_id = Reports::Status.all.map(&:id)

  Reports::Item.all.each do |item|
    item.reports_status_id = statuses_id.sample
    item.save!
  end
end
