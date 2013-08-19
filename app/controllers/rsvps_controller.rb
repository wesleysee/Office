class RsvpsController < ApplicationController

  http_basic_authenticate_with :name => "admin", :password => "02022011", :except => [:contact_us, :rsvp]

  def contact_us
    message =  "From: #{params['name']} &lt;#{params['email']}&gt;<br/><br/>\n"
    message +=  "Message:<br/>\n#{params['message']}"

    send_email(params['subject'], message)

    render :text => "success"
  end


  def rsvp
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.attending = params["attending"]

    message = "Name: #{@rsvp.first_name} #{@rsvp.last_name}<br/>\n"
    message += "Email: #{@rsvp.email}<br/>\n"
    message += "Phone: #{@rsvp.phone}<br/>\n"
    message += "Guests: #{@rsvp.guests}<br/>\n"
    message += "Notes: #{@rsvp.notes}<br/>\n"
    message += "Questions: #{@rsvp.questions}<br/>\n"

    if @rsvp.save
      send_email("RSVP: #{@rsvp.first_name} #{@rsvp.last_name} has responded #{@rsvp.attending ? 'Yes' : 'No'}", message)
      render :text => "success"
    else
      render :text => "failure"
    end
  end

  # GET /rsvp
  # GET /rsvp.json
  def index
    @rsvps = Rsvp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rsvp }
    end
  end

  # GET /rsvp/1
  # GET /rsvp/1.json
  def show
    @rsvp = Rsvp.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rsvp }
    end
  end

  # GET /rsvp/new
  # GET /rsvp/new.json
  def new
    @rsvp = Rsvp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rsvp }
    end
  end

  # GET /rsvp/1/edit
  def edit
    @rsvp = Rsvp.find(params[:id])
  end

  # POST /rsvp
  # POST /rsvp.json
  def create
    @rsvp = Rsvp.new(params[:rsvp])

    respond_to do |format|
      if @rsvp.save
        format.html { redirect_to @rsvp, notice: 'Rsvp was successfully created.' }
        format.json { render json: @rsvp, status: :created, location: @rsvp }
      else
        format.html { render action: "new" }
        format.json { render json: @rsvp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rsvp/1
  # PUT /rsvp/1.json
  def update
    @rsvp = Rsvp.find(params[:id])

    respond_to do |format|
      if @rsvp.update_attributes(params[:rsvp])
        format.html { redirect_to @rsvp, notice: 'Rsvp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rsvp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rsvp/1
  # DELETE /rsvp/1.json
  def destroy
    @rsvp = Rsvp.find(params[:id])
    @rsvp.destroy

    respond_to do |format|
      format.html { redirect_to rsvps_url }
      format.json { head :no_content }
    end
  end

  private
  def send_email(subject, message)
    ses = AWS::SimpleEmailService.new(
        :access_key_id => 'AKIAI66WTUU6RM5VW22A',
        :secret_access_key => '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')

    ses.send_email(
        :subject => subject,
        :from => 'wesleysee@gmail.com',
        :to => 'wesleysee@gmail.com',
        :body_html => message)
  end
end
