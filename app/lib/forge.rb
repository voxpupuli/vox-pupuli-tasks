class Forge
  def self.user
    @user ||= (
      PuppetForge.user_agent = "vox-pupuli-tasks"
      PuppetForge::User.find('puppet')
    )
  end

  def self.module(query)
    # this should never find two modules.
    # It will find zero modules if we never did a release
    # returns `nil` if zero
    @module ||= @user.modules.where(query: query).first
  end
end
