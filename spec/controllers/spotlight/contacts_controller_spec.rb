require 'spec_helper'

describe Spotlight::ContactsController do
  routes { Spotlight::Engine.routes }
  describe "when not logged in" do
    describe "GET edit" do
      let(:contact) { FactoryGirl.create(:contact) }
      it "should be successful" do
        get :edit, id: contact
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    let(:exhibit) { user.roles.first.exhibit }
    let(:contact) { FactoryGirl.create(:contact, exhibit: exhibit) }
    before {sign_in user }

    describe "GET edit" do
      it "should be successful" do
        get :edit, id: contact
        expect(response).to be_successful
      end
    end
    describe "PATCH update" do
      it "should be successful" do
        patch :update, id: contact, contact: {name: 'Chester'}
        expect(response).to redirect_to exhibit_about_pages_path(exhibit) 
        expect(contact.reload.name).to eq 'Chester'
      end
      it "should fail by rendering edit" do
        Spotlight::Contact.any_instance.should_receive(:update).and_return(false)
        patch :update, id: contact, contact: {name: 'Chester'}
        expect(response).to render_template 'edit'
      end
    end
    describe "DELETE destroy" do
      it "should be successful" do
        contact # force contact to be created
        expect {
          delete :destroy, id: contact
        }.to change{ Spotlight::Contact.count}.by(-1)
        expect(response).to redirect_to exhibit_about_pages_path(exhibit) 
      end
    end
    describe "GET new" do
      it "should be successful" do
        get :new, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end
    describe "POST create" do
      it "should fail by rendering new" do
        Spotlight::Contact.any_instance.should_receive(:update).and_return(false)
        post :create, exhibit_id: exhibit, contact: {name: 'Chester'}
        expect(response).to render_template 'new'
      end
      it "should be successful" do
        expect {
          post :create, exhibit_id: exhibit, contact: {name: 'Chester'}
        }.to change{ Spotlight::Contact.count}.by(1)
        expect(response).to redirect_to exhibit_about_pages_path(exhibit) 
      end
    end
  end
end