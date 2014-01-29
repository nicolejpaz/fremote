require 'spec_helper'

feature 'Create Fremote' do
  let!(:user) { FactoryGirl.create :user }
  let!(:fremote) { FactoryGirl.create :fremote }

  before(:each) do
    web_login user
  end

  context 'on host main page' do

    it 'can create fremote with valid input' do
      visit root_path
      fill_in 'video_url',   with: "Test Event"
      expect{click_button "Create Camping Trip"}.to change{Event.all.count}.by(1)
      expect(page).to have_content "Congratulations"
    end

    it 'goes to the event index page is a name is not passed in to the form' do
      visit host_events_path(host)
      fill_in 'event_name',   with: nil
      click_button "Create Camping Trip"
      expect(page).to have_content("Name can't be blank")
    end

  end

  describe 'Delete Event' do

    context 'on host events display page' do

      it 'can delete an event' do
        event = Event.create name: "whatever", host_id: 1, address: "Jenner Inn & Event Center, 25050 California 1, Jenner, CA"
        visit host_events_path(host)
        expect{click_link "X"}.to change{Event.all.count}.by(-1)
        expect(page).to_not have_content "Test Event"
      end

    end
  end

  describe 'add custom item' do

    context 'on single event page' do

      it 'can create a new item' do
        visit host_events_path(host)
        fill_in 'event_name',   with: "New Event"
        fill_in 'event_address', with: '717 California'
        click_button "Create Camping Trip"
        click_link "Let me get started already!"
        fill_in 'item_name', with: "Test Item"
        expect{click_button "Add Item"}.to change{Item.all.count}.by(1)
        expect(page).to have_content "Test Item"
      end

      it 'can change the state of an item to important' do
        event = Event.create name: "Test Event #2", host_id: host.id, address: "717 California"
        item = Item.create name: "Test Item #2", event_id: event.id
        visit host_events_path(host)
        click_link "Test Event #2"
        expect{click_link "essential_button"}.to change{item.reload.important}
      end

      it 'can change the state of an item to I got it' do
        event = Event.create name: "Test Event #2", host_id: host.id, address: "717 California"
        item = Item.create name: "Test Item #2", event_id: event.id
        guest = Guest.create
        guest_2 = Guest.create
        guest_3 = Guest.create
        visit host_event_path(host, event)
        expect(page).to have_content("no")
        expect{click_link "purchased_button"}.to change{item.reload.purchased}
      end

      it 'can remove an item from an events page' do
        event = Event.create name: "Test Event #2", host_id: host.id, address: "717 California"
        item = Item.create name: "Test Item #2", event_id: event.id
        guest = Guest.create
        guest_2 = Guest.create
        guest_3 = Guest.create
        visit host_event_path(host, event)
        expect(page).to have_content("no")
        expect{click_link "X"}.to change{Item.all}
      end

    end

    describe 'add custom item' do

      context 'on single event page' do

        it 'can update the location of an event' do
          event = Event.create name: "Test Event #2", host_id: host.id, address: "717 California"
          item = Item.create name: "Test Item #2", event_id: event.id
          visit host_events_path(host)
          click_link "Test Event #2"
          click_link "Edit Trip"
          fill_in "event_address", with: "224 Evergreen Drive"
          expect{click_button "Update"}.to change{event.reload.address}
        end
      end
    end
  end
end