bihar = State.find_or_create_by(name_en: 'Bihar', name_gu: 'બિહાર', name_hi: 'बिहार')
bihar_districts = [{ name_gu: 'ભોજપુર', name_en: 'Bhojpur', name_hi: 'भोजपुर' },
                   { name_gu: 'ભાગલપુર', name_en: 'Bhagalpur', name_hi: 'भागलपुर' }]
bihar_districts.each do |district|
  District.find_or_create_by(name_en: district[:name_en], name_gu: district[:name_gu], name_hi: district[:name_hi],
                             state: bihar)
end

assam = State.find_or_create_by(name_en: 'Assam', name_gu: 'આસામ', name_hi: 'असम')
assam_districts = [{ name_gu: 'દરરંગ', name_en: 'Darrang', name_hi: 'दरांग' },
                   { name_gu: 'ચારાઈદેવ', name_en: 'Charaideo', name_hi: 'चराइदेव' }]
assam_districts.each do |district|
  District.find_or_create_by(name_en: district[:name_en], name_gu: district[:name_gu], name_hi: district[:name_hi],
                             state: assam)
end

soil_types = [{ name_gu: 'પીટ માટી', name_en: 'Peat Soil', name_hi: 'पीट मिट्टी' },
              { name_gu: 'ચાક માટી', name_en: 'Chalk Soil', name_hi: 'चाक मिट्टी' },
              { name_gu: 'લોમ માટી', name_en: 'Loam Soil', name_hi: 'दोमट मिट्टी' }]

soil_types.each do |s|
  SoilType.find_or_create_by(name_en: s[:name_en], name_gu: s[:name_gu], name_hi: s[:name_hi])
end

admin = AdminUser.find_or_initialize_by(email: 'admin@example.com')
admin.update(password: 'password', password_confirmation: 'password')

About.create(text: '') unless About.first.present?
Policy.create(text: '') unless Policy.first.present?
