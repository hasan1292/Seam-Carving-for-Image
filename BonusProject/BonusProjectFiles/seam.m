function varargout = seam(varargin)

% Code developed by Hasan Iqbal. Student of Tsinghua University. ID: 280141

% Last Modified by GUIDE v2.5 15-Nov-2016 13:34:45


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seam_OpeningFcn, ...
                   'gui_OutputFcn',  @seam_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before seam is made visible.
function seam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seam (see VARARGIN)

% Choose default command line output for seam
handles.output = hObject;

a=imread('input.png');
axes(handles.axes1);
imshow(a);

b=imread('output.png');
axes(handles.axes2);
imshow(b);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 [filename, pathname] = uigetfile('*.*', 'Pick a MATLAB code file');
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
    else
       a=imread(filename);
       axes(handles.axes1);

       imshow(a);
       handles.a=a;
    end
    
% Update handles structure
guidata(hObject, handles);
    
% --- Executes on button press in VSeamCarving.
function VSeamCarving_Callback(hObject, eventdata, handles)
% hObject    handle to VSeamCarving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.a;

%get image loaded on axes1
[im]=a
success=nargout==0;

%Get the value of number of seams required from the slider
slider1 = get(handles.slider1,'Value');

%round the values to integers as they are received in decimals
k = round(slider1);

%convert the picture to double values
im=im2double(im);





if success
    %set the required values for showing Picture
    close(findobj(0,'type','figure','tag','seam carving'));
    figure; set(gcf,'tag','seam carving','name','Seam Carving','NumberTitle','off')
    axes('position', [0 0 1 1]);
    if size(im,3)==1
        im=im/max(im(:));
        him=imagesc(im);
        colormap gray
    else
        him=image(im);
    end
    axis equal
    axis off
end

for j=1:k
    %set the dimensions of dummy Array and pad it with All zeros
    FilteredPic=zeros(size(im,1),size(im,2));
    
    %Convert the picture to grayscale for energy using filter values       
    for i=1:size(im,3) 
        FilteredPic=FilteredPic+(filter2([.5 1 .5; 1 -6 1; .5 1 .5],im(:,:,i))).^2;
    end
    %calculate the shortest path available in FilteredPic
    ProcessedPic=FilteredPic;
    for i=2:size(ProcessedPic,1)
        previousPixel=ProcessedPic(i-1,:);
        iPos=previousPixel(1:end-1)<=previousPixel(2:end);
        previousPixel([false iPos])=previousPixel(iPos);
        iPos=previousPixel(2:end)<=previousPixel(1:end-1);
        previousPixel(iPos)=previousPixel([false iPos]);
        ProcessedPic(i,:)=ProcessedPic(i,:)+previousPixel;
    end

    %Process the pixels in vertical direction and go down
    pix=zeros(size(FilteredPic,1),1);
    [minPix,pix(end)]=min(ProcessedPic(end,:));
    previousPixel=find(ProcessedPic(end,:)==minPix);
    pix(end)=previousPixel(ceil(length(previousPixel)));
    
    %nan means inifinte
    im(end,pix(end),:)=nan;
    for i=size(FilteredPic,1)-1:-1:1
        [minPix,valuePix]=min(ProcessedPic(i,max(pix(i+1)-1,1):min(pix(i+1)+1,end)));
        pix(i)=valuePix+pix(i+1)-1-(pix(i+1)>1);
        %bitand means bitwise AND
        im(i,pix(i),:)=bitand(i,1);
    end

    if success
        set(him,'CDATA',im);
        drawnow;
    end

    %Remove the seam path from im and FilteredPic
    for i=1:size(im,1)
        im(i,pix(i):end-1,:)=im(i,pix(i)+1:end,:);
    end
    im(:,end,:)=[];

end

if success
    %Show the picture on the axes2 in seam.fig
    axes(handles.axes2);imshow(im);
     
end
if nargout==0
    clear im
end


    


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slider1 = get(hObject, 'Value');
assignin('base','slider1', slider1);
slider1 = round(slider1);
set (handles.text3, 'String', num2str(slider1));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slider2 = get(hObject, 'Value');
assignin('base','slider2', slider2);
slider2 = round(slider2);
set (handles.text5, 'String', num2str(slider2));


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in HSeamCarving.
function HSeamCarving_Callback(hObject, eventdata, handles)
% hObject    handle to HSeamCarving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.a;

% rotate the picture to 90 angle
b= imrotate(a,90);

%get image loaded on Axes1 after rotation
[im]=b
success=nargout==0;

%Get the value of number of seams required from the slider
slider2 = get(handles.slider2,'Value');

%round the values to integers as they are received in decimals
k = round(slider2);

%convert the picture to double values
im=im2double(im);





if success
    %set the required values for showing Picture
    close(findobj(0,'type','figure','tag','seam carving success'));
    figure; set(gcf,'tag','seam carving success','name','Seam Carving','NumberTitle','off')
    axes('position', [0 0 1 1]);
    if size(im,3)==1
        im=im/max(im(:));
        him=imagesc(im);
        colormap gray
    else
        him=image(im);
    end
    axis equal
    axis off
end


for j=1:k
    %set the dimensions of dummy Array and pad it with All zeros
    FilteredPic=zeros(size(im,1),size(im,2));
    
    %Convert the picture to grayscale for energy using filter values  
    for i=1:size(im,3) 
        FilteredPic=FilteredPic+(filter2([.5 1 .5; 1 -6 1; .5 1 .5],im(:,:,i))).^2;
    end
    
    %calculate the shortest path available in FilteredPic
    ProcessedPic=FilteredPic;
    for i=2:size(ProcessedPic,1)
        previousPixel=ProcessedPic(i-1,:);
        iPos=previousPixel(1:end-1)<previousPixel(2:end);
        previousPixel([false iPos])=previousPixel(iPos);
        iPos=previousPixel(2:end)<previousPixel(1:end-1);
        previousPixel(iPos)=previousPixel([false iPos]);
        ProcessedPic(i,:)=ProcessedPic(i,:)+previousPixel;
    end
    
    %Process the pixels in vertical direction and go down
    pix=zeros(size(FilteredPic,1),1);
    [minPix,pix(end)]=min(ProcessedPic(end,:));
    previousPixel=find(ProcessedPic(end,:)==minPix);
    pix(end)=previousPixel(ceil(length(previousPixel)));
    
    %nan means inifinte
    im(end,pix(end),:)=nan;
    for i=size(FilteredPic,1)-1:-1:1

        [minPix,valuePix]=min(ProcessedPic(i,max(pix(i+1)-1,1):min(pix(i+1)+1,end)));
        pix(i)=valuePix+pix(i+1)-1-(pix(i+1)>1);
        %bitand means bitwise AND
        im(i,pix(i),:)=bitand(i,1);

    end

    if success
        set(him,'CDATA',im);
        drawnow;
    end
    
    for i=1:size(im,1)
        im(i,pix(i):end-1,:)=im(i,pix(i)+1:end,:);
    end
    im(:,end,:)=[];

end

if success
    %Rotate back the picture to original orientation
    im2 = imrotate(im, -90);
    %Show the picture on the axes2 in seam.fig
    axes(handles.axes2);imshow(im2);

end
if nargout==0
    clear im
end


% --- Executes on button press in MSeam_Carving.
function MSeam_Carving_Callback(hObject, eventdata, handles)
% hObject    handle to MSeam_Carving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to VSeamCarving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.a;
%get image loaded on axes1
[im]=a
success=nargout==0;

%Get the value of number of seams required from the slider
slider1 = get(handles.slider1,'Value');

%round the values to integers as they are received in decimals
k = round(slider1);

%convert the picture to double values
im=im2double(im);




if success
    %set the required values for showing Picture
    close(findobj(0,'type','figure','tag','seam carving success'));
    figure; set(gcf,'tag','seam carving success','name','Seam Carving','NumberTitle','off')
    axes('position', [0 0 1 1]);
    if size(im,3)==1
        im=im/max(im(:));
        him=imagesc(im);
        colormap gray
    else
        him=image(im);
    end
    axis equal
    axis off
end


for j=1:k
    %set the dimensions of dummy Array and pad it with All zeros
    FilteredPic=zeros(size(im,1),size(im,2));
            
    %Convert the picture to grayscale for energy using filter values  
    for i=1:size(im,3) 
        FilteredPic=FilteredPic+(filter2([.5 1 .5; 1 -6 1; .5 1 .5],im(:,:,i))).^2;
    end
    %calculate the shortest path available in FilteredPic
    ProcessedPic=FilteredPic;
    for i=2:size(ProcessedPic,1)
        previousPixel=ProcessedPic(i-1,:);
        iPos=previousPixel(1:end-1)<=previousPixel(2:end);
        previousPixel([false iPos])=previousPixel(iPos);
        iPos=previousPixel(2:end)<=previousPixel(1:end-1);
        previousPixel(iPos)=previousPixel([false iPos]);
        ProcessedPic(i,:)=ProcessedPic(i,:)+previousPixel;
    end

    %Process the pixels in vertical direction and go down
    pix=zeros(size(FilteredPic,1),1);
    [minPix,pix(end)]=min(ProcessedPic(end,:));
    previousPixel=find(ProcessedPic(end,:)==minPix);
    pix(end)=previousPixel(ceil(length(previousPixel)));
    
    %nan means inifinte
    im(end,pix(end),:)=nan;
    for i=size(FilteredPic,1)-1:-1:1
        [minPix,valuePix]=min(ProcessedPic(i,max(pix(i+1)-1,1):min(pix(i+1)+1,end)));
        pix(i)=valuePix+pix(i+1)-1-(pix(i+1)>1);
        %bitand means bitwise AND
        im(i,pix(i),:)=bitand(i,1);
    end

    if success
        set(him,'CDATA',im);
        drawnow;
    end

    %Remove the seam path from im and FilteredPic
    for i=1:size(im,1)
        im(i,pix(i):end-1,:)=im(i,pix(i)+1:end,:);
    end
    im(:,end,:)=[];

end

success=nargout==0;

%now rotate already processed picture to 90 angle
im = imrotate(im, 90);

%Get the value of number of seams required from the slider
slider2 = get(handles.slider2,'Value');

%round the values to integers as they are received in decimals
k = round(slider2);

%convert the picture to double values
im=im2double(im);


if success
    %set the required values for showing Picture
    close(findobj(0,'type','figure','tag','seam carving success'));
    figure; set(gcf,'tag','seam carving success','name','Seam Carving','NumberTitle','off')
    axes('position', [0 0 1 1]);
    if size(im,3)==1
        im=im/max(im(:));
        him=imagesc(im);
        colormap gray
    else
        him=image(im);
    end
    axis equal
    axis off
end


for j=1:k
    %set the dimensions of dummy Array and pad it with All zeros
    FilteredPic=zeros(size(im,1),size(im,2));
    
    %Convert the picture to grayscale for energy using filter values  
    for i=1:size(im,3) 
        FilteredPic=FilteredPic+(filter2([.5 1 .5; 1 -6 1; .5 1 .5],im(:,:,i))).^2;       
    end
    
    %calculate the shortest path available in FilteredPic
    ProcessedPic=FilteredPic;
    for i=2:size(ProcessedPic,1)
        previousPixel=ProcessedPic(i-1,:);
        iPos=previousPixel(1:end-1)<previousPixel(2:end);
        previousPixel([false iPos])=previousPixel(iPos);
        iPos=previousPixel(2:end)<previousPixel(1:end-1);
        previousPixel(iPos)=previousPixel([false iPos]);
        ProcessedPic(i,:)=ProcessedPic(i,:)+previousPixel;
    end
    
    %Process the pixels in vertical direction and go down
    pix=zeros(size(FilteredPic,1),1);
    [minPix,pix(end)]=min(ProcessedPic(end,:));
    previousPixel=find(ProcessedPic(end,:)==minPix);
    pix(end)=previousPixel(ceil(length(previousPixel)));
    
    %nan means inifinte
    im(end,pix(end),:)=nan;
    for i=size(FilteredPic,1)-1:-1:1

        [minPix,valuePix]=min(ProcessedPic(i,max(pix(i+1)-1,1):min(pix(i+1)+1,end)));
        pix(i)=valuePix+pix(i+1)-1-(pix(i+1)>1);
        %bitand means bitwise AND
        im(i,pix(i),:)=bitand(i,1);

    end

    if success
        set(him,'CDATA',im);
        drawnow;
    end
    %Remove the seam path from im and FilteredPic
    for i=1:size(im,1)
        im(i,pix(i):end-1,:)=im(i,pix(i)+1:end,:);
    end
    im(:,end,:)=[];

end

if success
    %Rotate back the picture to original orientation
    im2 = imrotate(im, -90);
    %Show the picture on the axes2 in seam.fig
    axes(handles.axes2);imshow(im2);

end
if nargout==0
    clear im

end
