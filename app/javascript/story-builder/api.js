import axios from 'axios';

const requestConfig = () => ({
  headers: {
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    'X-Requested-With': 'XMLHttpRequest'
  }
})

const normalizeTags = (tags) => tags.map((tag) => tag.id || tag.name);

export const updateContent = (storyId, story, locale) => {
  const normalizedStory = {
    ...story,
    tag_ids: normalizeTags(story.tags)
  }

  if (storyId) {
    return axios.put(`/stories/${storyId}?story_locale=${locale}`, { story: normalizedStory }, requestConfig());
  } else {
    return axios.post(`/stories?story_locale=${locale}`, { story: normalizedStory }, requestConfig());
  }
}

export const uploadImage = (commonerId, file, onProgress) => {
  const form = new FormData();
  form.append("Content-Type", file.type);
  form.append("image[picture]", file);

  const options = {
    ...requestConfig(),
    onUploadProgress: progressEvent => onProgress((progressEvent.loaded / progressEvent.total) * 100)
  };

  return axios.post(`/commoners/${commonerId}/images`, form, options);
};
