class UsersController < Devise::RegistrationsController
  # load_and_authorize_resource
  
  respond_to :html
  respond_to :xml, :json, :only => [:index,:current_checkin]
  
  before_filter :authenticate_user!
  before_filter :account_exist?, :only => [:index]
  before_filter :safe_person, :only => [:edit,:update,:destroy]
  before_filter :secure_invitation, :only => [:accept_invitation,:denied_invitation]
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.order('created_at desc').page params[:page]
    respond_with(@users)
  end
  
  def current_checkin
    @users = Kaminari.paginate_array(User.all(:order=>'firstname').select { |p| p.checkin? }).page(params[:page])
    respond_with(@users) do |format|
      format.html { render :action => :index }
      format.json { render :action => :index }
      format.xml { render :action => :index }
    end
  end
  
  def denied_invitation
    @invitation.denied!
    flash[:notice] = "Ok bye bye #{@invitation.follower.name} !"
    respond_with(@user)
  end
  
  def accept_invitation
    @invitation.accept!
    flash[:success] = "You follow #{@invitation.follower.name} now !"
    respond_with(@user)
  end
    
  def request_an_invitation
    @followed = User.find(params[:id])
    @follower = current_user
    @followed.invitation!(@follower)
    flash[:success] = "Your request has been sent with succes"
    respond_with(@user) do |format|
      format.html { redirect_to users_path }
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    super
  end

  # GET /users/1/edit
  def edit
    super
  end

  # POST /users
  # POST /users.xml
  def create
    super
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    super
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    super
  end
  
  private 

  def safe_person
    @user = (current_user.is_admin?) ? User.find(params[:id]) : current_user
  end

  def secure_invitation
    @user = current_user
    @invitation = Invitation.find(params[:id])
    unless @user == @invitation.followed
      respond_with do |format|
        flash[:error] = "This operation is forbiden"
        format.html { redirect_to :action => :show }
      end
    end
  end
  
end