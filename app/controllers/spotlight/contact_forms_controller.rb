module Spotlight
  class ContactFormsController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    def new
      @contact_form = Spotlight::ContactForm.new :current_url => request.referer
    end

    def create
      @contact_form = Spotlight::ContactForm.new(contact_form_params)
      @contact_form.current_exhibit = current_exhibit
      @contact_form.request = request

      if @contact_form.valid?
        if @contact_form.respond_to? :deliver_now
          @contact_form.deliver_now
        else
          @contact_form.deliver
        end

        redirect_to :back, notice: t(:'helpers.submit.contact_form.created')
      else
        render 'new' 
      end
      
    end

    protected
    def contact_form_params
      params.require(:contact_form).permit(:name, :email, :message, :current_url)
    end
  end
end
