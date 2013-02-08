require 'spec_helper'

describe Spree::SpreeLandlord::TenantSeeder do
  let(:spree_default_seeds_dir) {
    File.join(Gem.loaded_specs['spree_core'].full_gem_path, 'db', 'default')
  }

  def load_seed_data(seed_file)
    YAML.load_file(File.join(spree_default_seeds_dir, seed_file))
  end

  let(:roles_seed_data) {
    load_seed_data('spree/roles.yml')
  }

  let(:countries_seed_data) {
    load_seed_data('spree/countries.yml')
  }

  let(:states_seed_data) {
    load_seed_data('spree/states.yml')
  }

  let(:zones_seed_data) {
    load_seed_data('spree/zones.yml')
  }

  let(:zone_members_seed_data) {
    load_seed_data('spree/zone_members.yml')
  }

  let!(:tenant) {
    Spree::Tenant.new.tap do |t|
      t.stub(:seed_tenant)
      t.shortname = 'test'
      t.domain = 'test.dev'
      t.save!
    end
  }

  let(:seeder) {
    Spree::SpreeLandlord::TenantSeeder.new(tenant)
  }

  before do
    Spree::Tenant.set_current_tenant(tenant)
  end

  describe '#seed' do
    before do
      seeder.seed
    end

    it 'generates all roles in spree core' do
      roles_seed_data.each do |key, values|
        expect(Spree::Role.where(:name => values['name']).count).to be == 1
      end
    end

    it 'generates all countries in spree_core' do
      countries_seed_data.each do |key, values|
        country_query = Spree::Country.where(:name => values['name'])

        expect(country_query.count).to be == 1

        country = country_query.first
        expect(country.iso3).to eq(values['iso3'])
        expect(country.iso).to eq(values['iso'])

        # the seed data in spree_core is incomplete for Serbia
        # the values here are sourced from http://www.unc.edu/~rowlett/units/codes/country.htm
        unless country.name == 'Serbia'
          expect(country.iso_name).to eq(values['iso_name'])
          expect(country.numcode).to eq(values['numcode'].to_i)
        else
          expect(country.iso_name).to eq('REPUBLIC OF SERBIA')
          expect(country.numcode).to eq(688)
        end
      end
    end

    it 'generates all states in spree_core' do
      united_states = Spree::Country.where(:iso => 'US').first

      states_seed_data.each do |key, values|
        state_query = Spree::State.where(:name => values['name'])
        expect(state_query.count).to be == 1

        state = state_query.first
        expect(state.country).to eq(united_states)
        expect(state.abbr).to eq(values['abbr'])
      end
    end

    it 'generates all zones in spree_core' do
      zones_seed_data.each do |key, values|
        zone_query = Spree::Zone.where(:name => values['name'])

        expect(zone_query.count).to be == 1

        zone = zone_query.first
        expect(zone.created_at).to eq(values['created_at'])
        expect(zone.updated_at).to eq(values['updated_at'])
        expect(zone.description).to eq(values['description'])
      end
    end

    it 'generates all zone members in spree_core' do
      zones_ids_map = {
        1 => Spree::Zone.where(name: 'EU_VAT').first.id,
        2 => Spree::Zone.where(name: 'North America').first.id
      }

      zoneables_ids_map = {
        13 => Spree::Country.where(iso3: 'AUT').first.id,
        20 => Spree::Country.where(iso3: 'BEL').first.id,
        30 => Spree::Country.where(iso3: 'BGR').first.id,
        35 => Spree::Country.where(iso3: 'CAN').first.id,
        51 => Spree::Country.where(iso3: 'CYP').first.id,
        52 => Spree::Country.where(iso3: 'CZE').first.id,
        53 => Spree::Country.where(iso3: 'DNK').first.id,
        62 => Spree::Country.where(iso3: 'EST').first.id,
        67 => Spree::Country.where(iso3: 'FIN').first.id,
        68 => Spree::Country.where(iso3: 'FRA').first.id,
        74 => Spree::Country.where(iso3: 'DEU').first.id,
        90 => Spree::Country.where(iso3: 'HUN').first.id,
        96 => Spree::Country.where(iso3: 'IRL').first.id,
        98 => Spree::Country.where(iso3: 'ITA').first.id,
        110 => Spree::Country.where(iso3: 'LVA').first.id,
        116 => Spree::Country.where(iso3: 'LTU').first.id,
        117 => Spree::Country.where(iso3: 'LUX').first.id,
        125 => Spree::Country.where(iso3: 'MLT').first.id,
        142 => Spree::Country.where(iso3: 'NLD').first.id,
        162 => Spree::Country.where(iso3: 'POL').first.id,
        163 => Spree::Country.where(iso3: 'PRT').first.id,
        167 => Spree::Country.where(iso3: 'ROM').first.id,
        183 => Spree::Country.where(iso3: 'SVK').first.id,
        184 => Spree::Country.where(iso3: 'SVN').first.id,
        188 => Spree::Country.where(iso3: 'ESP').first.id,
        194 => Spree::Country.where(iso3: 'SWE').first.id,
        213 => Spree::Country.where(iso3: 'GBR').first.id,
        214 => Spree::Country.where(iso3: 'USA').first.id,
      }

      zone_members_seed_data.each do |key, values|
        zone_member_query = Spree::ZoneMember.where(
          zone_id: zones_ids_map[values['zone_id'].to_i],
          zoneable_id: zoneables_ids_map[values['zoneable_id'].to_i])

        expect(zone_member_query.count).to be == 1

        zone = zone_member_query.first
        expect(zone.created_at).to eq(values['created_at'])
        expect(zone.updated_at).to eq(values['updated_at'])
        expect(zone.zoneable_type).to eq(values['zoneable_type'])
      end
    end
  end
end
