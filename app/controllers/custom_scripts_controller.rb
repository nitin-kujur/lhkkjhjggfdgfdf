class CustomScriptsController < ApplicationController

  layout false
  def update_quantity
  	puts params.inspect
    respond_to do |format|
      format.html { }
      format.json { }
      format.js {}
    end
  end
end