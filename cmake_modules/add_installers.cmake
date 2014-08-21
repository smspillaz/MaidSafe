#==================================================================================================#
#                                                                                                  #
#  Copyright 2014 MaidSafe.net limited                                                             #
#                                                                                                  #
#  This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,        #
#  version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which    #
#  licence you accepted on initial access to the Software (the "Licences").                        #
#                                                                                                  #
#  By contributing code to the MaidSafe Software, or to this project generally, you agree to be    #
#  bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root        #
#  directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also available   #
#  at: http://www.maidsafe.net/licenses                                                            #
#                                                                                                  #
#  Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed    #
#  under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF   #
#  ANY KIND, either express or implied.                                                            #
#                                                                                                  #
#  See the Licences for the specific language governing permissions and limitations relating to    #
#  use of the MaidSafe Software.                                                                   #
#                                                                                                  #
#==================================================================================================#
#                                                                                                  #
#  Sets up installer targets for Win/Unix platforms.                                               #
#==================================================================================================#

# Installer Types
set(Types Farmer Dev Utilities DevDebug)

set(FarmerExeDepends vault vault_manager)
set(DevLibDepends maidsafe_common
                  maidsafe_passport
                  maidsafe_rudp
                  maidsafe_routing
                  maidsafe_encrypt
                  maidsafe_api
                  maidsafe_nfs_core
                  maidsafe_nfs_client
                  BoostSystem
                  BoostChrono
                  BoostDateTime
                  BoostFilesystem
                  BoostLocale
                  BoostProgramOptions
                  BoostRegex
                  BoostThread
                  BoostSerialization
                  cryptopp
                  protobuf_lite
                  sqlite)
set(UtilitiesExeDepends test_common
                        test_rudp
                        test_routing
                        test_routing_api
                        test_drive
                        test_passport
                        test_nfs
                        test_encrypt
                        test_filesystem
                        test_api)
set(DevDebugLibDepends ${DevLibDepends})

if(UNIX)
  set(FarmerName "maidsafe-farmer")
  set(DevName "maidsafe-dev")
  set(UtilitiesName "maidsafe-utilities")
  set(DevDebugName "maidsafe-dev-dbg")

  set(InstallerScriptName "installer_unix.cmake")
elseif(MSVC)
  set(FarmerName "Farmer")
  set(DevName "Dev")
  set(UtilitiesName "Utilities")
  set(DevDebugName "DevDebug")

  set(InstallerScriptName "installer_msvc.cmake")
else()
  message(STATUS "Installer targets not available in this platform")
  return()
endif()

function(safe_path InPath OutPath)
  set(${OutPath} "\"\"${InPath}\"\"" PARENT_SCOPE)
endfunction()

# Create Custom Installer Targets
foreach(Type ${Types})
  foreach(LibDepend ${${Type}LibDepends})
    safe_path($<TARGET_FILE:${LibDepend}> SafePath)
    list(APPEND ${Type}Libs ${SafePath})

    get_target_property(Headers ${LibDepend} INTERFACE_INCLUDE_DIRECTORIES)
    if(Headers)
      safe_path(${Headers} SafePath)
      list(APPEND ${Type}Headers ${SafePath})
    endif()

    get_target_property(SystemHeaders ${LibDepend} INTERFACE_SYSTEM_INCLUDE_DIRECTORIES)
    if(SystemHeaders)
      safe_path(${SystemHeaders} SafePath)
      list(APPEND ${Type}Headers ${SafePath})
    endif()
  endforeach()

  foreach(ExeDepend ${${Type}ExeDepends})
    safe_path($<TARGET_FILE:${ExeDepend}> SafePath)
    list(APPEND ${Type}Exes ${SafePath})
  endforeach()

  add_custom_target(${${Type}Name}
                    COMMAND ${CMAKE_COMMAND}
                        -DCMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}"
                        -DTargetName="${${Type}Name}"
                        -DTargetType=${Type}
                        -DTargetLibs="${${Type}Libs}"
                        -DTargetHeaders="${${Type}Headers}"
                        -DTargetExes="${${Type}Exes}"
                        -DConfig=$<CONFIGURATION>
                        -P "${CMAKE_SOURCE_DIR}/cmake_modules/${InstallerScriptName}"
                        -V)
  set_target_properties(${${Type}Name} PROPERTIES FOLDER "MaidSafe/Installers")
endforeach()