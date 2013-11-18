namespace :spree_landlord do
  namespace :tenant do
    desc 'Generates a new tenant with optional sample products'
    task :create => :environment do
      require 'highline/import'
      require 'ffaker'

      def prompt_for_shortname
        ask('Tenant Short Name: ') do |q|
          q.default = Faker::Internet.domain_word
          q.validate = lambda { |a| a.present? }
          q.responses[:not_valid] = 'The short name must be provided'
          q.whitespace = :strip
        end
      end

      def prompt_for_domain
        ask('Tenant Domain: ') do |q|
          q.default = Faker::Internet.domain_name
          q.validate = lambda { |a| a.present? }
          q.responses[:not_valid] = 'The domain must be provided'
          q.whitespace = :strip
        end
      end

      def generate_sample_products?
        agree('Generate sample products? ') do |q|
          q.default = 'yes'
          q.whitespace = :strip
        end
      end

      shortname = prompt_for_shortname
      domain = prompt_for_domain

      tenant = Spree::Tenant.create!(:shortname => shortname, :domain => domain)

      if generate_sample_products?
        PRICES = [
          2.99, 4.99, 7.99, 8.99, 12.99, 15.99, 16.99, 17.99, 18.99,
          19.99, 21.99, 22.99, 26.99, 28.99, 29.99, 30.99, 32.99, 35.99, 36.99,
          38.99, 39.99, 40.99, 41.99, 42.99, 43.99, 45.99, 48.99, 49.99, 50.99,
          51.99, 53.99, 54.99, 56.99, 58.99, 60.99, 64.99, 66.99, 67.99, 68.99,
          69.99, 72.99, 74.99, 75.99, 76.99, 78.99, 79.99, 82.99, 84.99, 85.99,
          86.99, 88.99, 89.99, 90.99, 92.99, 94.99, 95.99, 96.99, 97.99, 98.99,
          99.99, 100.99, 102.99, 103.99, 106.99, 107.99, 108.99, 110.99, 111.99,
          114.99, 115.99, 117.99, 118.99, 119.99, 120.99, 122.99, 123.99,
          124.99, 129.99, 131.99, 133.99, 134.99, 136.99, 137.99, 142.99,
          143.99, 145.99, 147.99, 152.99, 155.99, 156.99, 158.99, 159.99,
          160.99, 161.99, 162.99, 164.99, 167.99, 172.99, 173.99, 174.99,
          176.99, 179.99, 180.99, 182.99, 185.99, 186.99, 187.99, 188.99,
          190.99, 191.99, 192.99, 193.99, 194.99, 196.99, 197.99, 198.99,
          199.99, 200.99, 201.99, 202.99, 204.99, 205.99, 207.99, 210.99,
          211.99, 214.99, 215.99, 216.99, 217.99, 218.99, 219.99, 221.99,
          222.99, 223.99, 224.99, 225.99, 229.99, 230.99, 231.99, 232.99,
          234.99, 235.99, 237.99, 239.99, 240.99, 241.99, 242.99, 243.99,
          246.99, 247.99, 248.99, 249.99, 250.99, 251.99, 254.99, 256.99,
          259.99, 260.99, 261.99, 262.99, 263.99, 264.99, 265.99, 266.99,
          272.99, 273.99, 274.99, 275.99, 276.99, 278.99, 280.99, 282.99,
          284.99, 285.99, 286.99, 288.99, 291.99, 292.99, 293.99, 296.99,
          297.99, 299.99, 300.99, 301.99, 302.99, 303.99, 304.99, 305.99,
          307.99, 308.99, 309.99, 310.99, 312.99, 313.99, 314.99, 315.99,
          316.99, 317.99
        ]

        Spree::Tenant.set_current_tenant(tenant)

        brands = Spree::Taxonomy.create!(name: 'Brand')

        10.times do
          brand_name = Faker::Product.brand
          puts "... Creating brand #{brand_name}"
          brand = Spree::Taxon.create!(name: brand_name)
          brands.root.children << brand
        end
        random=Random.new
        50.times do
          product_name = Faker::Product.product_name
          puts "... Creating product #{product_name}"
          price=PRICES.sample
          product = Spree::Product.create!(
            name: product_name,
            price: price,
            cost_price: price*random.rand(0.4..0.6),
            msrp: price*random.rand(1.4..1.8),
            available_on: 1.week.ago,
            description: Faker::Lorem.paragraph(10))
          open("http://cambelt.co/390x320/#{CGI.escape(product_name)}?color=234653,eeeeee") do |image_io|
            image = product.images.new
            image.attachment = image_io
            image.save!
          end

          product.taxons << brands.root.children.sample
        end
      end
    end
  end
end

namespace :db do
  task :load_file => :reset_column_information do
    Spree::SpreeLandlord::TenantMigrator.new.move_unassigned_to_master
  end

  task :migrate => :reset_column_information do
    # clear tables that are seeded by spree_core
    Spree::Country.delete_all
    Spree::State.delete_all
    Spree::Zone.delete_all
    Spree::Role.delete_all
    Spree::ZoneMember.delete_all
  end

  task :reset_column_information do
    ActiveRecord::Base.send(:subclasses).each do |model|
      model.connection.schema_cache.clear!
      model.reset_column_information
    end
  end
end
