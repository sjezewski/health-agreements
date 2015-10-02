require 'protected_controller'

class PracticesController < ProtectedController

  def create
    current_company
    @practice = @company.practices.create(allowed_params)

    if @practice.save
      redirect_to company_path(@company)
    else
      render 'edit'
    end
  end

  def show
    current_company
    @practice = Practice.find(params[:id])

    # syntactic sugar to reuse table partial (on company/arch show pages)
    @guideline = @practice.guideline
    @description = @practice.notes
  end

  def edit
    current_company
    @practice = Practice.find(params[:id])
  end

  def update
    current_company
    @practice = Practice.find(params[:id])

    if @practice.update(allowed_params)
      redirect_to @company
    else
      render 'edit'
    end
  end

  def destroy
    current_company

    @practice = Practice.find(params[:id])
    @practice.destroy

    redirect_to @company
  end

  def autocomplete_implementations
    raw = view_context.enumerated_implementations
    opts = raw.collect do |pair|
      normalized_text = pair.first.to_s.split("_").join(" ").capitalize
      {
        :label => normalized_text,
        :value => normalized_text,
        :enumerated_value => pair.last,
        :id => pair.last
      }
    end
    render json: opts
  end

  private

  def allowed_params
    # need to whitelist foreign_id for guideline? and owner company?
    params.require(:practice).permit(:implementation, :notes, :guideline_id)
  end

  def current_company
    @company ||= Company.where(slug: params[:company_id]).first
  end

end
