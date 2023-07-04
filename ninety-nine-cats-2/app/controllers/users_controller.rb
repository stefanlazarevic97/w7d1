class UsersController < ApplicationController
    def show
        @user = User.find_by(id: params[:id])
        render :show
    end
    
    def new
        @user = User.new
        render :new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            login(@user)
            redirect_to cats_url
        else
            render :new
        end
    end

    private
    def user_params
        params.require(:user).permit(:username, :password)
    end
end
